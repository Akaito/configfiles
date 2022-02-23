SHELL = /bin/bash

#####
#=== variables ===

# Linux
uname_s := $(shell uname -s)
# i386, x86_64, armv71
uname_m := $(shell uname -m)
# Android, GNU/Linux
uname_o := $(shell uname -o)
# 4.4.0-18362-Microsoft
uname_r := $(shell uname -r)
# Use this way later:
# ifneq (,$(findstring Microsoft,$(uname_r)))  # if WSL

# https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
# https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


.PHONY: help \
	all \
	configs \
	alacritty bash git nvim termux tmux vim \
	keys \
	apt apt-install apt-beyondcompare apt-syncthing \
	rust \
	pip pip3-install \
	iptables \
	samba ssh sshd

help:
	@echo 'Use `make <tab><tab>` to see what options are available.'


all: configs keys apt
	if [ ! -f ~/.TODO.md ]; then cp TODO-output.md ~/TODO.md ; fi
	cat ~/TODO.md

#test: | $(shell which vim)
test:
	@#echo $(mkfile_dir)
	@#$(info uname_m=$(uname_m))
	@echo "mkfile_path: [$(mkfile_path)]"
	@echo "mkfile_dir: [$(mkfile_dir)]"
	@echo "realpath of dir-ssh/config: [$(realpath $(mkfile_dir)ssh/config)]"
	@echo "realpath of dir-/ssh/config: [$(realpath $(mkfile_dir)/ssh/config)]"


#####
#=== configs ===

configs: alacritty bash git nvim ssh termux tmux vim

alacritty:
ifneq ($(uname_o),Android)
	mkdir --parents ~/.config
	if [ -d ~/.config/alacritty && ! -d ~/.config/alacritty-makebak ]; then mv ~/.config/alacritty{,-makebak}; fi
	rm -rf ~/.config/alacritty
	ln -sf $(realpath alacritty) ~/.config/alacritty
endif  # neq Android

bash:
ifeq ($(uname_o),Android)
	cp bash/bashrc-android ~/.bashrc
else
	@# bashrc
	@if [ -f ~/.bashrc ]; then mv ~/.bashrc ~/.bashrc-makebak; fi
	ln bash/bashrc-debian ~/.bashrc
	@# dircolors (colors 'ls' and such output)
	@if [ -f ~/.dircolors ]; then mv ~/.dircolors ~/.dircolors-makebak; fi
	ln bash/dircolors ~/.dircolors
endif
	. ~/.bashrc


git:
ifeq ($(uname_o),Android)
	cp git/gitconfig ~/.gitconfig
else
	@if [ -f ~/.gitconfig ]; then mv ~/.gitconfig ~/.gitconfig-makebak; fi
	ln -sf $(mkfile_dir)/git/gitconfig ~/.gitconfig
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
ifneq ($(uname_o),Android)
	mkdir --parents ~/.config
	if [ -d ~/.config/nvim && ! -d ~/.config/nvim-makebak ]; then mv ~/.config/nvim{,-makebak}; fi
	rm -rf ~/.config/nvim
	ln -sf $(realpath nvim) ~/.config/nvim
endif


ssh:
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [[ -f ~/.ssh/config && ! -L ~/.ssh/config ]] ; then mv ~/.ssh/config{,-makebak} ; fi
	@# Can't symlink this one since the link's permissions will upset SSH.
	ln -f $(realpath $(mkfile_dir)ssh/config) ~/.ssh/config


termux:
ifeq ($(uname_o),Android)
	cp termux/base16-monokai.properties ~/.termux/colors.properties
endif


tmux:
	if [[ -f ~/.tmux.conf && ! -L ~/.tmux.conf && ! -f ~/.tmux.conf-makebak ]] ; then mv ~/.tmux.conf ~/.tmux.conf-makebak ; fi
	if [[ -d ~/.tmux && ! -L ~/.tmux && ! -d ~/.tmux-makebak ]]; then mv ~/.tmux ~/.tmux-makebak ; fi
	-git submodule update --init --recursive $(realpath $(mkfile_dir)tmux/tmux/plugins)
ifeq ($(uname_o),Android)
	cp -r tmux/tmux ~/.tmux
	cp tmux/tmux.conf ~/.tmux.conf
else
	ln -sf $(realpath $(mkfile_dir)tmux/tmux) ~/.tmux
	ln -sf $(realpath $(mkfile_dir)tmux/tmux.conf) ~/.tmux.conf
endif
	-if [ `command -v tmux` ]; then tmux source-file ~/.tmux.conf; fi


vim: install-vim config-vim
config-vim:
	mkdir --parents ~/.vimdid
ifeq ($(uname_o),Android)
	rm -rf ~/.vim
	cp -r vim ~/.vim
	cp vim/vimrc ~/.vimrc
else
	rm -rf ~/.vim
	rm -f ~/.vimrc
	ln -sf $(realpath $(mkfile_dir)vim) ~/.vim
	ln -sf $(realpath $(mkfile_dir)vim/vimrc) ~/.vimrc
	vim -c PlugUpgrade -c PlugUpdate -c qa
endif


#####
#=== security - networking ===
iptables:
	echo TODO
	# Ensure package `iptables-persistent` is installed.
	# Append(? or copy/ln?) iptables/rules.v4 over to /etc/iptables/rules.v4
	# Look into rules.v6
	# service netfilter-persistent reload


#=== keys ===

keys: key-ssh


key-ssh: ~/.ssh/id_ed25519 ~/.ssh/id_rsa

~/.ssh/id_%:
	ssh-keygen -t %* -C "$(USER)@$(shell hostname)"


#=== installations ===

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

install-vim:
ifeq ($(strip $(shell which vim)),)
	os-install-vim
endif

os-install-%:
	sudo apt-get update
	sudo apt-get install -y $*


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
		byzanz
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

pip: pip3-install

pip2-install:
ifneq ($(uname_o),Android)
	sudo pip install --upgrade pip
endif

pip3-install:
ifneq ($(uname_o),Android)
	sudo apt install python3-pip
	sudo pip3 install --upgrade pip
	sudo pip3 install awscli
	@#aws configure
endif


#=== daemon config : sambad ===

samba:
ifneq ($(uname_o),Android)
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [[ -f /etc/samba/smb.conf && ! -L /etc/samba/smb.conf ]] ; then sudo mv /etc/samba/smb.conf{,-makebak}; fi
	if [[ -f /etc/samba/smbusers && ! -L /etc/samba/smbusers ]] ; then sudo mv /etc/samba/smbusers{,-makebak}; fi
	sudo ln -sf $(realpath samba/smb.conf) /etc/samba/smb.conf
	sudo ln -sf $(realpath samba/smbusers) /etc/samba/smbusers
	# setup smb user(s)
	sudo smbpasswd -a $(USER)
endif


#=== daemon config : sshd ===

sshd:
ifneq ($(uname_o),Android)
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [[ -f /etc/ssh/sshd_config && ! -L /etc/ssh/sshd_config ]] ; then sudo mv /etc/ssh/sshd_config{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/sshd_config) /etc/ssh/sshd_config
	if [[ -f /etc/pam.d/sshd && ! -L /etc/pam.d/sshd ]] ; then sudo mv /etc/pam.d/sshd{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/pam.d/sshd) /etc/pam.d/sshd
	@# per-user
	if [[ -f ~/.ssh/authorized_keys && ! -L /etc/ssh/sshd_config ]] ; then sudo mv ~/.ssh/authorized_keys{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/authorized_keys) ~/.ssh/authorized_keys
endif

