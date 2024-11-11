#!/bin/bash

# Check to see if Miniforge is installed and if not, install it
function install-miniforge()
{
    if [ -f ~/miniforge.installed ]; then
        echo "Miniforge already installed, skipping"
    else
        wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
	bash Miniforge3.sh -b -p $HOME/conda
	echo 'export PATH="$HOME/conda/bin:$PATH"' >> ~/.profile
	rm Miniforge3.sh
	source ~/.profile
	conda init bash
	echo "Miniforge has been installed" > ~/miniforge.installed
	clear
	echo ""
	echo ""
	echo "I'm about to reboot, please re-run script after reboot (Ctrl+C to exit script and cancel reboot)."
	sudo reboot
    fi
}


# Install as much as i can via bioconda
function install-biocondatools()
{
    # Create a python 3.10 environment as some tools (primarily Unicycler) are not compatible with newer Python versions
    mamba create -n py310 -y -c conda-forge -c bioconda -c defaults python=3.10 clonalframeml clustalo fastqc gubbins kma raxml-ng panaroo sourmash spyder unicycler mashtree snippy snpEff=5.0 fastp snp-dists multiqc mlst abricate quast
    # This is a fix for Prokka
    mamba env config vars set PERL5LIB=$HOME/miniconda/lib/perl5/site_perl/5.22.0/ -n base
    # Set py310 environment as the default environment
    echo "mamba activate py310" >> ~/.bashrc
    # Create a python 2.7 environment for the tools that are not compatible with python 3
    mamba create -n py27 -y -c conda-forge -c bioconda -c defaults python=2.7 srst2
}


# Install goofys
function install-goofys()
{
    sudo wget  -P /usr/local/bin  https://github.com/APHA-AMR-VIR/NewVMBasicProgInstall/blob/main/goofys
    sudo chmod +x /usr/local/bin/goofys
}


# Install UGENE
function install-ugene()
{
    sudo apt-get update
    sudo apt-get install -y ugene
    sudo apt-get install -y ugene-non-free
    sudo apt-get install -y ugene-data
}


# Install Easyfig
function install-easyfig()
{
    cd $HOME
    wget https://github.com/mjsull/Easyfig/releases/download/2.2.2/Easyfig_2.2.2_linux.tar.gz
    tar -xvf Easyfig_2.2.2_linux.tar.gz
    echo 'PATH=$PATH:$HOME/Easyfig_2.2.2_linux' >> ~/.profile
    rm Easyfig_2.2.2_linux.tar.gz
}


# Install BRIG
function install-brig()
{
    sudo apt-get update && sudo apt-get install -y brig
}


# Install LibreOffice
function install-libreoffice()
{
    sudo apt-get update && sudo apt-get install -y libreoffice
}


# Install Filezilla
function install-filezilla()
{
    sudo apt-get update && sudo apt-get install -y filezilla
}


# Install R & RStudio
function install-RandRStudio()
{
    # Add R repository to APT sources.list
    if [[ $(lsb_release -rs) == "20.04" ]]
    then
        echo "Ubuntu 20.04 found"
        if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" /etc/apt/sources.list
        then
            echo "R repo already in sources.list"
        else
            echo deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/ | sudo tee --append /etc/apt/sources.list
        fi
    elif [[ $(lsb_release -rs) == "22.04" ]]
    then
        echo "Ubuntu 22.04 found"
            if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" /etc/apt/sources.list
            then
                echo "R repo already in sources.list"
            else
                echo deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/ | sudo tee --append /etc/apt/sources.list
            fi
    elif [[ $(lsb_release -rs) == "24.04" ]]
    then
        echo "Ubuntu 24.04 found"
            if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" /etc/apt/sources.list
            then
                echo "R repo already in sources.list"
            else
                echo deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/ | sudo tee --append /etc/apt/sources.list
            fi
    else
        echo "Non-compatible version"
    fi

    # Add R repository keys the proper way
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

    # Add R repository keys the workaround way (this didn't work when i tried it on 28/10/2024)
    # gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    # gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

    # Update repository list and install R
    sudo apt-get update && sudo apt-get install r-base r-base-dev -y

    # Install RStudio Server
    sudo apt-get install gdebi-core -y
    if [[ $(lsb_release -rs) == "20.04" ]]
    then
        wget https://www.rstudio.org/download/latest/stable/server/focal/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
    elif [[ $(lsb_release -rs) == "22.04" ]]
    then
        wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
    elif [[ $(lsb_release -rs) == "24.04" ]]
    then
        wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
    else
        echo "Non-compatible version"
    fi
    sudo gdebi --non-interactive rstudio-latest.deb
    rm rstudio-latest.deb
}


# Completion message
function completion-message()
{
    clear
    echo ""
    echo ""
    echo "*******************************************************************************************"
    echo "* All your software packages are installed now. Please reboot before you try to use them. *"
    echo "*******************************************************************************************"
    echo ""
    echo ""
}


# Mount S3 bucket
function mount-s3bucket()
{
    echo "If you wish you can now specify an S3 bucket to mount, if you don't want to do this at this time press Ctrl-C."
    read -p "S3 bucket to mount: " S3BUCKET
    mkdir -p ~/mnt/$S3BUCKET
    echo -e "goofys $S3BUCKET ~/mnt/$S3BUCKET" >> ~/.bashrc
}


install-miniforge
install-biocondatools
install-goofys
install-ugene
install-easyfig
install-brig
install-libreoffice
install-filezilla
install-RandRStudio
completion-message
mount-s3bucket
