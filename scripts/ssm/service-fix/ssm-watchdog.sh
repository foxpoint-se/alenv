#!/bin/bash

# SSM Agent Watchdog Script
# Monitors SSM agent connectivity and restarts service if needed

set -e

# Configuration
MAX_RETRIES=12  # 2 minutes with 10-second intervals
RETRY_INTERVAL=10
HEALTH_CHECK_INTERVAL=30
LOG_FILE="/var/log/ssm-watchdog.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO: $1"
    echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
    log "WARN: $1"
    echo -e "${YELLOW}WARN:${NC} $1"
}

log_error() {
    log "ERROR: $1"
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if SSM agent is running
check_ssm_running() {
    systemctl is-active --quiet amazon-ssm-agent
}

# Check if SSM agent can reach AWS (basic connectivity test)
check_ssm_connectivity() {
    # First, test basic responsiveness
    if ! test_ssm_responsiveness; then
        log_warn "SSM agent not responsive to basic commands"
        return 1
    fi
    
    # Use ssm-cli diagnostics for comprehensive connectivity check
    local diagnostics_output
    local critical_checks=0
    local failed_checks=0
    
    # Run diagnostics with timeout
    if ! diagnostics_output=$(timeout 30 sudo ssm-cli get-diagnostics --output json 2>/dev/null); then
        log_warn "SSM diagnostics command failed or timed out"
        return 1
    fi
    
    # Use jq to parse JSON and check critical connectivity items
    local critical_items=(
        "Hybrid instance registration"
        "Connectivity to ssm endpoint"
        "Connectivity to ec2messages endpoint"
        "Connectivity to ssmmessages endpoint"
        "Agent service"
    )
    
    for item in "${critical_items[@]}"; do
        local status=$(echo "$diagnostics_output" | jq -r --arg check "$item" '.DiagnosticsOutput[] | select(.Check == $check) | .Status' 2>/dev/null)
        
        if [ "$status" = "Success" ]; then
            critical_checks=$((critical_checks + 1))
        elif [ "$status" != "" ]; then
            critical_checks=$((critical_checks + 1))
            failed_checks=$((failed_checks + 1))
            log_warn "Critical check failed: $item ($status)"
        fi
    done
    
    # If we have critical checks and none failed, we're good
    if [ $critical_checks -gt 0 ] && [ $failed_checks -eq 0 ]; then
        log_info "SSM connectivity confirmed via diagnostics ($critical_checks critical checks passed)"
        return 0
    elif [ $critical_checks -eq 0 ]; then
        log_warn "No critical checks found in diagnostics output"
        return 1
    else
        log_warn "SSM connectivity check failed ($failed_checks/$critical_checks critical checks failed)"
        return 1
    fi
}

# Check if wwan0 interface is up and has connectivity
check_wwan_connectivity() {
    # Check if interface exists
    if ! ip link show wwan0 >/dev/null 2>&1; then
        return 1
    fi
    
    # Check if interface is up (wwan0 can show UNKNOWN state but still be working)
    if ! ip link show wwan0 | grep -q "UP"; then
        return 1
    fi
    
    # Check if we have a default route via wwan0
    if ! ip route show default | grep -q "wwan0"; then
        return 1
    fi
    
    # Basic internet connectivity test
    if ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Simple connectivity test to AWS SSM endpoints
check_aws_connectivity() {
    # Test connectivity to SSM endpoints (common regions)
    local ssm_endpoints=(
        "ssm.us-east-1.amazonaws.com"
        "ssm.us-west-2.amazonaws.com"
        "ssm.eu-west-1.amazonaws.com"
    )
    
    for endpoint in "${ssm_endpoints[@]}"; do
        if timeout 5 bash -c "</dev/tcp/$endpoint/443" 2>/dev/null; then
            log_info "AWS connectivity confirmed via $endpoint"
            return 0
        fi
    done
    
    log_warn "No AWS SSM endpoint connectivity"
    return 1
}

# Test SSM diagnostics command
test_ssm_diagnostics() {
    log_info "Testing SSM diagnostics command..."
    
    if timeout 10 sudo ssm-cli get-diagnostics --output json >/dev/null 2>&1; then
        log_info "SSM diagnostics command working"
        return 0
    else
        log_warn "SSM diagnostics command failed"
        return 1
    fi
}

# Quick SSM agent responsiveness test
test_ssm_responsiveness() {
    local instance_info
    
    if instance_info=$(timeout 10 sudo ssm-cli get-instance-information 2>/dev/null); then
        # Parse the JSON response to verify we got valid instance info
        local instance_id=$(echo "$instance_info" | jq -r '.instance-id' 2>/dev/null)
        local region=$(echo "$instance_info" | jq -r '.region' 2>/dev/null)
        
        if [ "$instance_id" != "null" ] && [ "$region" != "null" ]; then
            log_info "SSM agent responsive - Instance: $instance_id, Region: $region"
            return 0
        else
            log_warn "SSM agent responded but returned invalid instance information"
            return 1
        fi
    else
        log_warn "SSM agent not responsive to get-instance-information"
        return 1
    fi
}

# Restart SSM agent service
restart_ssm_service() {
    log_warn "Restarting SSM agent service..."
    systemctl restart amazon-ssm-agent
    sleep 5  # Give it time to start
}

# Wait for initial connectivity
wait_for_initial_connectivity() {
    log_info "Waiting for initial wwan0 connectivity..."
    
    local timeout=300  # 5 minutes
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if check_wwan_connectivity; then
            log_info "wwan0 connectivity confirmed"
            return 0
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
        log_info "Waiting for wwan0 connectivity... ($elapsed/$timeout seconds)"
    done
    
    log_error "Timeout waiting for initial wwan0 connectivity"
    return 1
}

# Main watchdog loop
main() {
    log_info "SSM Watchdog starting..."
    
    # Wait for initial connectivity
    if ! wait_for_initial_connectivity; then
        log_error "Failed to establish initial connectivity, exiting"
        exit 1
    fi
    
    # Start SSM agent if not running
    if ! check_ssm_running; then
        log_info "Starting SSM agent service..."
        systemctl start amazon-ssm-agent
        sleep 10  # Give it time to start
    fi
    
    # Test SSM diagnostics command
    if ! test_ssm_diagnostics; then
        log_warn "SSM diagnostics command not working, will use fallback checks"
    fi
    
    log_info "Starting watchdog loop..."
    
    local consecutive_failures=0
    local health_check_count=0
    
    while true; do
        health_check_count=$((health_check_count + 1))
        
        # Check if SSM agent is running
        if ! check_ssm_running; then
            log_warn "SSM agent not running, attempting restart..."
            restart_ssm_service
            consecutive_failures=$((consecutive_failures + 1))
        else
            # Check connectivity
            if check_ssm_connectivity; then
                if [ $consecutive_failures -gt 0 ]; then
                    log_info "SSM connectivity restored after $consecutive_failures failures"
                fi
                consecutive_failures=0
                
                # Log successful health check every 10 checks
                if [ $((health_check_count % 10)) -eq 0 ]; then
                    log_info "SSM agent healthy (check #$health_check_count)"
                fi
            else
                consecutive_failures=$((consecutive_failures + 1))
                log_warn "SSM connectivity check failed (failure #$consecutive_failures)"
                
                # Check if wwan0 is still up
                if ! check_wwan_connectivity; then
                    log_error "wwan0 connectivity lost, waiting for recovery..."
                    # Wait for wwan0 to come back
                    while ! check_wwan_connectivity; do
                        sleep 10
                    done
                    log_info "wwan0 connectivity restored"
                fi
                
                # Check AWS connectivity as fallback
                if ! check_aws_connectivity; then
                    log_warn "AWS connectivity also failed"
                fi
                
                # Restart service if we've had multiple consecutive failures
                if [ $consecutive_failures -ge 3 ]; then
                    log_warn "Multiple connectivity failures, restarting SSM agent..."
                    restart_ssm_service
                fi
                
                # Remove exit after max retries; just log a warning and keep going
                if [ $consecutive_failures -ge $MAX_RETRIES ]; then
                    log_warn "Exceeded maximum retries ($MAX_RETRIES), but will keep trying..."
                    consecutive_failures=0
                fi
            fi
        fi
        
        # Sleep before next check
        if [ $consecutive_failures -gt 0 ]; then
            # More frequent checks when there are issues
            sleep $RETRY_INTERVAL
        else
            # Normal health check interval
            sleep $HEALTH_CHECK_INTERVAL
        fi
    done
}

# Handle script termination
cleanup() {
    log_info "SSM Watchdog stopping..."
    exit 0
}

trap cleanup SIGTERM SIGINT

# Run main function
main "$@" 