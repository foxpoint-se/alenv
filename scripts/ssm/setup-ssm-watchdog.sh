#!/bin/bash

# Setup SSM Watchdog Service
# Installs and configures the SSM agent watchdog for reliable connectivity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}INFO:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

log_step() {
    echo -e "${BLUE}STEP:${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Get script directory
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
}

# Install watchdog script
install_watchdog_script() {
    local script_dir=$(get_script_dir)
    local source_script="$script_dir/ssm-watchdog.sh"
    local target_script="/usr/local/bin/ssm-watchdog.sh"
    
    log_step "Installing watchdog script..."
    
    if [ ! -f "$source_script" ]; then
        log_error "Watchdog script not found: $source_script"
        exit 1
    fi
    
    cp "$source_script" "$target_script"
    chmod +x "$target_script"
    
    log_info "Watchdog script installed to $target_script"
}

# Install systemd service
install_systemd_service() {
    local script_dir=$(get_script_dir)
    local source_service="$script_dir/ssm-watchdog.service"
    local target_service="/etc/systemd/system/ssm-watchdog.service"
    
    log_step "Installing systemd service..."
    
    if [ ! -f "$source_service" ]; then
        log_error "Service file not found: $source_service"
        exit 1
    fi
    
    cp "$source_service" "$target_service"
    
    log_info "Systemd service installed to $target_service"
}

# Enable and start service
enable_service() {
    log_step "Enabling and starting watchdog service..."
    
    systemctl daemon-reload
    systemctl enable ssm-watchdog.service
    systemctl start ssm-watchdog.service
    
    log_info "Watchdog service enabled and started"
}

# Check service status
check_service_status() {
    log_step "Checking service status..."
    
    if systemctl is-active --quiet ssm-watchdog.service; then
        log_info "Watchdog service is running"
    else
        log_warn "Watchdog service is not running"
        systemctl status ssm-watchdog.service --no-pager -l
    fi
}

# Show usage information
show_usage() {
    echo "SSM Watchdog Setup Script"
    echo ""
    echo "This script installs and configures a watchdog service that monitors"
    echo "SSM agent connectivity and automatically restarts the service if needed."
    echo ""
    echo "Features:"
    echo "  - Waits for wwan0 connectivity before starting SSM agent"
    echo "  - Monitors SSM agent connectivity to AWS"
    echo "  - Automatically restarts service on connectivity failures"
    echo "  - Configurable retry limits and intervals"
    echo "  - Comprehensive logging"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --status       Check service status after installation"
    echo "  --logs         Show recent watchdog logs"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install and enable watchdog"
    echo "  $0 --status           # Install and show status"
    echo "  $0 --logs             # Show recent logs"
}

# Show logs
show_logs() {
    log_step "Recent watchdog logs:"
    echo ""
    
    if [ -f "/var/log/ssm-watchdog.log" ]; then
        tail -20 "/var/log/ssm-watchdog.log"
    else
        log_warn "No watchdog log file found"
    fi
    
    echo ""
    log_step "Recent systemd logs:"
    echo ""
    journalctl -u ssm-watchdog.service --no-pager -l -n 20
}

# Main function
main() {
    local show_status=false
    local show_logs=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            --status)
                show_status=true
                shift
                ;;
            --logs)
                show_logs=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if just showing logs
    if [ "$show_logs" = true ]; then
        show_logs
        exit 0
    fi
    
    log_info "Starting SSM Watchdog Setup..."
    
    # Check root privileges
    check_root
    
    # Install components
    install_watchdog_script
    install_systemd_service
    enable_service
    
    # Show status if requested
    if [ "$show_status" = true ]; then
        check_service_status
    fi
    
    log_info "SSM Watchdog setup complete!"
    echo ""
    log_info "Service management commands:"
    echo "  sudo systemctl status ssm-watchdog.service    # Check status"
    echo "  sudo systemctl restart ssm-watchdog.service   # Restart service"
    echo "  sudo systemctl stop ssm-watchdog.service      # Stop service"
    echo "  sudo journalctl -u ssm-watchdog.service -f    # Follow logs"
    echo ""
    log_info "Watchdog log file: /var/log/ssm-watchdog.log"
}

# Run main function
main "$@" 