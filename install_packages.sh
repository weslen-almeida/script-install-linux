#!/bin/bash
#Developer: Weslen Almeida

# Load absolute path to script, dirname parameter strips the script name from the end of the path 
# and readlink resolves the name of absolute path. $0 is the relative path.
file_directory=$(dirname -- $(readlink -fn -- "$0"))

# Detect Operational System in use.
distro=$(lsb_release -i | cut -f 2-)
#USER=$(ps -o user= -p $$ | awk '{print $1}')

add_user_sudoers(){
    
    if [[ $(id -u) == 0 ]]; then
        echo "Which User do you want to add in Sudoers File?: "
        read user
        echo "$user  ALL=(ALL:ALL) ALL" >> /etc/sudoers
        echo "User added to sudoers file. Now you can use sudo command!"
        start_function
    
    else
        echo "You must be root to run this function"
        echo "Please execute this script as root and run this option again."
        start_function

    fi
}

# Enable Flatpak support.
enable_flatpak(){ #OK
    
    echo "Please reboot your system after install these packages."
    echo "Flatpak services requires a reboot to work correctly!"
    sudo apt install flatpak && sudo apt install --reinstall ca-certificates
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo
    echo "Flatpak Successfully installed and enabled."
    start_function
}

# Remove file that blocks Snap in Linux Mint and enable it for installation or install Snap in Debian.
enable_snap(){ #OK

    echo "Please reboot your system after install these packages."
    echo "Snap services requires a reboot to work correctly!"

    if [[ $distro == "Linuxmint" ]]; then 
        sudo rm /etc/apt/preferences.d/nosnap.pref
        echo "Support to Snap Enabled"
        echo "Installing Snap Service..."
        sudo apt install snapd
        start_function

    elif [[ $distro == "Debian" ]]; then
        echo "Installing Snap Service..."
        sudo apt install snapd
        start_function

    elif [[ $distro == "Ubuntu" ]]; then
        echo "Ubuntu already has Snap support."
        start_function

    else 
        echo "Your Operational System is not supported. This script only supports Debian 11, Linux Mint 20.x and Ubuntu 20.04"
        exit
    fi
}

# Function responsible for install flatpak applications.. 
# Reading the file and iterating line by line to install packages.
flatpak_packages(){
    
    echo "This option installs a collection of flatpak packages."
    sleep 1
    while IFS= read -r line || [[ -n "$line" ]]; do
        sudo flatpak install -y "$line"
    done < "$flatpak_programs"
    echo
    echo "Flatpak packages installed"
    start_function
}

# Function responsible for install snap applications. 
# Reading the file and iterating line by line to install packages.
snap_packages(){ #OK

    echo "This option installs a collection of snap packages."
    sleep 1
    while IFS= read -r line || [[ -n "$line" ]]; do
        sudo snap install "$line"
    done < "$snap_programs"
    echo
    echo "Snap packages installed"
    start_function
}

# Function responsible for install deb applications through apt-get. 
# Reading the file and iterating line by line to install packages.
apt_packages(){ #OK

    echo "This option installs a collection of general and essential packages."
    sleep 1
    #sudo apt update
    while IFS= read -r line || [[ -n "$line" ]]; do
        sudo apt install $line -y
    done < "$apt_programs"
    echo
    echo "Deb packages have been installed."
    start_function   
}

# Function clone repository construp
construp_git(){

    echo "creat folder construp in ~/construp"
    sleep 1
    mkdir ~/construp
    cd ~/construp
    sleep 1

     echo "This option installs a collection of flatpak packages."
    sleep 1
    while IFS= read -r line || [[ -n "$line" ]]; do
        git clone git@github.com:Constr-Up/"$line"
    done < "$construp_repository"
    echo
    echo "Success"
    
    start_function   
}

# Function clone repository construp
config-git-debian(){

    echo "Install git"
    sleep 1
    sudo apt install git

    echo "Config username and email git"
    sleep 1
    git config --global user.name "Weslen Almeida"
    git config --global user.email "weslengomes@gmail.com"

    echo "Gnerate ssh-key"
    sleep 1
    ssh-keygen -t ed25519 -C "weslengomes@gmail.com"

    echo "Adding ssh to the ssh-agent"
    sleep 1
    eval "$(ssh-agent -s)"

    echo "Adding ssh private ssh-agent"
    sleep 1
    ssh-add ~/.ssh/id_ed25519
    
    echo "Copy key and Add key in github page"
    echo "-----------------------------------"
    sleep 1
    cat ~/.ssh/id_ed25519.pub
 
    echo "Success"
    
    start_function   
}

install_docker_debian(){

    echo "Install Prerequisites"
    sleep 1
    sudo apt install apt-transport-https ca-certificates curl

    echo "Add Docker’s GPG Repo Key"
    sleep 1
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

    echo "Add the Docker Repo to Pop!_OS 22.04"
    sleep 1
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

    echo "Install Docker on Pop!_OS 22.04 LTS"
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    sleep 1
    echo "Active docker in startup system"
    sudo systemctl is-active docker
    
    sleep 1
    echo "user sudo docker"
    sudo usermod -aG docker ${USER}

    start_function   
}

install_nvm_puro_and_flutter(){

    echo "Install Puro (Flutter)"
    sleep 1
    curl -o- https://puro.dev/install.sh | PURO_VERSION="1.4.6" bash

    sleep 1
    echo "Create new environment from a release channel"
    puro create stable_flutter stable

    echo "install nvm"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    source ~/.bashrc
    sleep 1

    start_function   
}

# Shows to user the packages installation options. 
start_function(){
echo
echo "Please select an option."
echo
echo "1  - APT - General and Essential Packages"
echo "2  - SNAP - Enable and Install Snap Service"
echo "3  - FLATPAK - Enable and Install Flatpak service"
echo "4  - SNAP - Install Snap Packages"
echo "5 - FLATPAK - Install Flatpak Packages"
echo "6 - Add user to sudoers file"
echo "7 - Clone Repository Construp"
echo "8 - Install Docker"
echo "9 - Install and config git"
echo "10 - Install FVM, PURO AND FLUTTER"
echo "11 - Close application"
echo

# It receives the user's choice and loads the files in .txt format.
# Calls the function responsible for reading the file and iterating line by line to install the programs.
while :
do
  read select_option
  case $select_option in

	1)  apt_programs="$file_directory/txt_files/apt_programs.txt"
        apt_packages;;
	
    2)  enable_snap;;

    3)  enable_flatpak;;

    4)  snap_programs="$file_directory/txt_files/snap_packages.txt"
        snap_packages;;
    
    5) flatpak_programs="$file_directory/txt_files/flatpak_packages.txt"
        flatpak_packages;;
    
    6) add_user_sudoers;;

    7) construp_repository="$file_directory/txt_files/construp_repository.txt"
        construp_git;;
    
    8) install_docker_debian;; 
    
    9) config-git-debian;;

    10) install_nvm_puro_and_flutter;;

    11) exit

  esac
done
}

start_function

