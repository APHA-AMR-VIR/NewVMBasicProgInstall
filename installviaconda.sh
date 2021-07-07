#!/bin/bash
# name is installviaconda.sh
# Check to see if Miniconda is installed and if not, install it
function install-miniconda()
{
    if [ -f ~/conda.installed ]; then
        echo "Conda already installed, skipping"
    else
        curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	sh Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda
	echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.profile
	rm Miniconda3-latest-Linux-x86_64.sh
	source ~/.profile
	conda init bash
	echo "Miniconda has been installed" > ~/conda.installed
	clear
	echo "I'm about to reboot, please re-run script after reboot."
	sudo reboot
    fi
}


# Install as much as i can via conda
function install-condatools()
{
    # Create a python 3.6 environment as some tools (primarily Gubbins) are not compatible with python 3.8
    conda create -n py36 -y -c conda-forge -c bioconda -c defaults python=3.6 beagle beast clonalframeml clustalo fastqc gubbins kma mauve nullarbor raxml-ng scoary sistr_cmd sourmash unicycler
    # This is a fix for Prokka
    conda env config vars set PERL5LIB=$HOME/miniconda/lib/perl5/site_perl/5.22.0/ -n base
    # Set py36 environment as the default environment
    echo "conda activate py36" >> ~/.bashrc
    # Create a python 2.7 environment for the tools that are not compatible with python 3
    conda create -n py27 -y -c conda-forge -c bioconda -c defaults python=2.7 quast srst2
}


# Install APHASeqFinder
function install-aphaseqfinder()
{
    cd $HOME
    git clone https://github.com/APHA-AMR-VIR/APHASeqFinder
    sudo ln -s $HOME/APHASeqFinder/seqfinder.py /usr/local/bin
}


# Install goofys
function install-goofys()
{
    sudo wget  -P /usr/local/bin  https://github.com/kahing/goofys/releases/latest/download/goofys
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


# Install cgMLSTFinder
function install-cgmlstfinder()
{
    cd $HOME
    git clone https://bitbucket.org/genomicepidemiology/cgmlstfinder.git
    sudo cp ~/cgmlstfinder/cgMLST.py /usr/local/bin
    sudo cp ~/cgmlstfinder/make_nj_tree.py /usr/local/bin
    rm -fr ~/cgmlstfinder
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


# Install SPIDER
function install-spider()
{
    cd $HOME
    wget http://www.bioinformatics.org/spider/SPIDER_WORK.tar.gz
    tar -xvf SPIDER_WORK.tar.gz
    echo 'PATH=$PATH:$HOME/SPIDER_WORK' >> ~/.profile
    rm SPIDER_WORK.tar.gz
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
    echo deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/ | sudo tee --append /etc/apt/sources.list

    # Add R repository keys
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

    # Update repository list and install R
    sudo apt-get update && sudo apt-get install r-base r-base-dev -y

    # Install RStudio-Server
    sudo apt-get install gdebi-core -y
    wget -P ~ https://www.rstudio.org/download/latest/stable/server/bionic/rstudio-server-latest-amd64.deb
    sudo gdebi --non-interactive ~/rstudio-server-latest-amd64.deb
    rm ~/rstudio-server-latest-amd64.deb
}


# Mount S3 bucket
function mount-s3bucket()
{
    read -p "S3 bucket to mount: " S3BUCKET
    mkdir -p ~/mnt/$S3BUCKET
    echo -e "goofys $S3BUCKET ~/mnt/$S3BUCKET" >> ~/.bashrc
}


install-miniconda
install-condatools
install-aphaseqfinder
install-goofys
install-ugene
install-cgmlstfinder
install-easyfig
install-brig
install-spider
install-libreoffice
install-filezilla
install-RandRStudio
mount-s3bucket