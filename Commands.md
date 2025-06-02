# Install just
choco install just

<!-- # Start K8s with KIND
just setup-cluster -->

# Complete demo setup (If KIND cluster already setup then the setup-cluster step will return error you can ignore that error)
just demo

# Then
just deploy

# Test it
just test

# Check status  
just status

# Cleanup   ***Definitely run this at the end, to uninstall pip packages that were globally installed during `just demo`
just cleanup-all