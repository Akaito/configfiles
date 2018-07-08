.PHONY: all \
	configs bash git vim \
	keys \
	apt apt-install apt-beyondcompare \
	pip pip3-install


all: configs keys apt pip

test:
	echo foo


#=== configs ===

configs: bash git vim

bash:
	rm -f ~/.bashrc
	ln bash/bashrc-debian ~/.bashrc


git:
	rm -f ~/.gitconfig
	ln git/gitconfig ~/.gitconfig


vim:
	rm -rf ~/.vim
	rm -f ~/.vimrc
	ln -s vim ~/.vim
	ln vim/vimrc ~/.vimrc


#=== keys ===

keys: key-ssh


key-ssh: ~/.ssh/id_rsa

~/.ssh/id_rsa:
	ssh-keygen -b 4096 -t rsa -C "$(USER)@$(shell hostname)"


#=== installations : apt ===

apt: apt-install apt-beyondcompare

apt-install:
	sudo apt-get update
	sudo apt-get install \
		vim git \
		docker \
		clang \
		libsdl2-dev libsdl2-gfx-dev libsdl2-ttf-dev \
		libsdl2-doc

apt-beyondcompare:
	wget http://www.scootersoftware.com/bcompare-4.2.5.23088_amd64.deb
	sudo apt-get install gdebi-core
	sudo gdebi bcompare-4.2.5.23088_amd64.deb
	rm bcompare-4.2.5.23088_amd64.deb


#=== installations : pip ===

pip: pip2-install pip3-install

pip2-install:
	pip install --upgrade pip

pip3-install:
	pip3 install --upgrade pip
	sudo pip3 install awscli
	aws configure

