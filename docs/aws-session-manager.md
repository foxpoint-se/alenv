[⬅ Back to main README](../README.md)

# Setting up AWS Session Manager

## Setting up the RPi

TODO

## Setting up your computer

Add this to your `~/.ssh/config`:

```
# SSH over AWS Systems Manager Session Manager
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    IdentityFile ~/.ssh/id_rsa
    SetEnv GIT_AUTHOR_NAME="Your Name" GIT_AUTHOR_EMAIL="your.email@example.com" GIT_COMMITTER_NAME="Your Name" GIT_COMMITTER_EMAIL="your.email@example.com"
    SendEnv GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL AWS_VAULT AWS_REGION AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION
    ForwardAgent yes
```

And then connect with `ssh ubuntu@mi-XXXYYYZZZ` where `XXXYYYZZZ` is found in AWS Console.
