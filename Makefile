# Linux
uname_s := $(shell uname -s)
# i386, x86_64, armv71
uname_m := $(shell uname -m)
# Android
uname_o := $(shell uname -o)

# https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
# https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


.PHONY: all \
	configs bash git ncmpcpp nvim termux tmux vim \
	keys \
	apt apt-install apt-beyondcompare apt-syncthing \
	pip pip3-install \
	samba ssh sshd


all: configs keys apt pip
	if [ ! -f ~/.TODO.md ]; then cp TODO-output.md ~/TODO.md ; fi
	cat ~/TODO.md

test:
	@#echo $(mkfile_dir)
	@#$(info uname_m=$(uname_m))
	echo $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
	echo $(mkfile_path)
	echo $(mkfile_dir)


#=== configs ===

configs: bash git ncmpcpp nvim ssh termux tmux vim

bash:
ifeq ($(uname_o),Android)
	cp bash/bashrc-termux ~/.bashrc
else
	rm -f ~/.bashrc
	ln bash/bashrc-debian ~/.bashrc
endif
	. ~/.bashrc


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


nvim:
	mkdir --parents ~/.config
	rm -rf ~/.config/nvim
	ln -sf $(realpath nvim) ~/.config/nvim


ssh:
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [ -f ~/.ssh/config && ! -L ~/.ssh/config ] ; then mv ~/.ssh/config{,-makebak}; fi
	ln -sf $(realpath ssh/config) ~/.ssh/config


termux:
ifeq ($(uname_o),Android)
	cp termux/base16-monokai.properties ~/.termux/colors.properties
endif


tmux:
	rm ~/.tmux.conf
ifeq ($(uname_o),Android)
	cp tmux/tmux.conf ~/.tmux.conf
else
	ln -s $(mkfile_dir)/tmux/tmux.conf ~/.tmux.conf
endif
	if [ `command -v tmux` ]; then tmux source-file ~/.tmux.conf; fi


vim:
ifeq ($(uname_o),Android)
	rm -rf ~/.vim
	cp -r vim ~/.vim
	cp vim/vimrc ~/.vimrc
else
	rm -rf ~/.vim
	rm -f ~/.vimrc
	ln -sf $(mkfile_dir)/vim ~/.vim
	ln -f $(mkfile_dir)/vim/vimrc ~/.vimrc
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
		curl wget screen tmux \
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
	wget http://www.scootersoftware.com/bcompare-4.2.9.23626_amd64.deb
	sudo apt-get install gdebi-core
	sudo gdebi bcompare-4.2.9.23626_amd64.deb
	rm bcompare-4.2.9.23626_amd64.deb
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
	sudo apt install python3-pip
	sudo pip3 install --upgrade pip
	sudo pip3 install awscli
	aws configure
endif


#=== daemon config : sambad ===

samba:
ifneq ($(uname_o),Android)
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [ -f /etc/samba/smb.conf && ! -L /etc/samba/smb.conf ] ; then sudo mv /etc/samba/smb.conf{,-makebak}; fi
	if [ -f /etc/samba/smbusers && ! -L /etc/samba/smbusers ] ; then sudo mv /etc/samba/smbusers{,-makebak}; fi
	sudo ln -sf $(realpath samba/smb.conf) /etc/samba/smb.conf
	sudo ln -sf $(realpath samba/smbusers) /etc/samba/smbusers
	# setup smb user(s)
	sudo smbpasswd -a chris
endif


#=== daemon config : sshd ===

sshd:
ifneq ($(uname_o),Android)
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [ -f /etc/ssh/sshd_config && ! -L /etc/ssh/sshd_config ] ; then sudo mv /etc/ssh/sshd_config{,-makebak}; fi
	sudo ln -sf $(realpath ssh/sshd_config) /etc/ssh/sshd_config
	if [ -f /etc/pam.d/sshd && ! -L /etc/pam.d/sshd ] ; then sudo mv /etc/pam.d/sshd{,-makebak}; fi
	sudo ln -sf $(realpath ssh/pam.d/sshd) /etc/pam.d/sshd
	@# per-user
	if [ -f ~/.ssh/authorized_keys && ! -L /etc/ssh/sshd_config ] ; then sudo mv ~/.ssh/authorized_keys{,-makebak}; fi
	sudo ln -sf $(realpath ssh/authorized_keys) ~/.ssh/authorized_keys
endif

