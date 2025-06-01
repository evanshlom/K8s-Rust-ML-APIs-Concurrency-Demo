# Install just
choco install just

<!-- # Start K8s with KIND
just setup-cluster -->

# Complete demo setup
just demo

# Test it
just test

# Check status  
just status

# Cleanup   ***Definitely run this at the end, to uninstall pip packages that were globally installed during `just demo`
just cleanup-all