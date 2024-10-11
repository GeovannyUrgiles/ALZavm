# Post Deployment Script to add WSL2 to a Self-Hosted Build Runner VM

wsl --install -d Ubuntu-20.04 --user root -- sh -c "apt update && apt upgrade -y && apt install -y git curl wget zsh"
wsl --s Ubuntu-20.04