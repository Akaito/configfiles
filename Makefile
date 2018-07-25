# Linux
uname_s := $(shell uname -s)
# i386, x86_64, armv71
uname_m := $(shell uname -m)
# Android
uname_o := $(shell uname -o)


.PHONY: all \
	configs bash git ncmpcpp vim \
	keys \
	apt apt-install apt-beyondcompare apt-syncthing \
	pip pip3-install


all: configs keys apt pip
	if [ ! -f ~/.TODO.md ]; then cp TODO-output.md ~/TODO.md ; fi
	cat ~/TODO.md

test:
	$(info uname_m=$(uname_m))


#=== configs ===

configs: bash git ncmpcpp vim

bash:
ifeq ($(uname_o),Android)
	cp bash/bashrc-termux ~/.bashrc
else
	rm -f ~/.bashrc
	ln bash/bashrc-debian ~/.bashrc
endif


git:
ifeq ($(uname_o),Android)
	cp git/gitconfig ~/.gitconfig
else
	rm -f ~/.gitconfig
	ln git/gitconfig ~/.gitconfig
endif


ncmpcpp:
ifneq ($(uname_o),Android)
	if [ ! -d ~/.ncmpcpp ]; then mkdir ~/.ncmpcpp; fi
	rm -f ~/.ncmpcpp/bindings
	ln ncmpcpp/bindings ~/.ncmpcpp/bindings
	# Only copy config file if doesn't exist, since private data will be entered in the local-only copy.
	if [ ! -f ~/.ncmpcpp/config ]; then cp ncmpcpp/config ~/.ncmpcpp/config; fi
endif


vim:
ifeq ($(uname_o),Android)
	rm -rf ~/.vim
	cp -r vim ~/.vim
	cp vim/vimrc ~/.vimrc
else
	rm -rf ~/.vim
	rm -f ~/.vimrc
	ln -s vim ~/.vim
	ln vim/vimrc ~/.vimrc
endif


#=== keys ===

keys: key-ssh


key-ssh: ~/.ssh/id_rsa

~/.ssh/id_rsa:
	ssh-keygen -b 4096 -t rsa -C "$(USER)@$(shell hostname)"


#=== installations : apt ===

apt: apt-install apt-beyondcompare apt-syncthing

apt-install:
ifneq ($(uname_o),Android)
	sudo apt-get update
	sudo apt-get install \
		vim git lynx \
		syncthing keepass2 \
		docker \
		clang \
		cmake \
		libsdl2-dev libsdl2-gfx-dev libsdl2-ttf-dev \
		libsdl2-doc \
		byzanz \
		ncmpcpp
endif

apt-beyondcompare:
ifeq ($(uname_m),x86_64)
	wget http://www.scootersoftware.com/bcompare-4.2.5.23088_amd64.deb
	sudo apt-get install gdebi-core
	sudo gdebi bcompare-4.2.5.23088_amd64.deb
	rm bcompare-4.2.5.23088_amd64.deb
else
	@echo WARN: BeyondCompare install not supported on this architecture.
endif

# not really an "apt-*" target; may rename later
# https://docs.syncthing.net/users/autostart.html?highlight=daemon#linux
# recall default Web GUI address of 127.0.0.1:8384
apt-syncthing:
ifneq ($(uname_o),Android)
	systemctl --user enable syncthing.service
	systemctl --user start syncthing.service
endif


#=== installations : pip ===

pip: pip2-install pip3-install

pip2-install:
ifneq ($(uname_o),Android)
	sudo pip install --upgrade pip
endif

pip3-install:
ifneq ($(uname_o),Android)
	sudo pip3 install --upgrade pip
	sudo pip3 install awscli
	aws configure
endif

