SHELL = /bin/bash
#APT_GET = apt-get --no-allow-insecure-repositories --error-on=any --show-progress
APT_GET = apt-get
SYS_PKG_INSTALL = sudo apt-get --show-progress install

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
desktop_env := $(strip ${XDG_CURRENT_DESKTOP})

# https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
# https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

OBSIDIAN_VERSION := 0.14.5


.PHONY: help \
	all \
	configs \
	alacritty bash git nvim obsidian termux tmux vim \
	keys \
	apt apt-install apt-tier0 apt-tier1 apt-tier2 \
	beyondcompare apt-gpg apt-syncthing apt-tmux \
	aws \
	rust \
	pip pip2-install pip3-install \
	iptables \
	redshift \
	samba ssh sshd sshd2fa \
	flatpak flatpak-install-obsidian \
	gnome system76

help:
	@echo 'Use `make <tab><tab>` to see what options are available.'


all: configs keys apt
	if [ ! -f ~/.TODO.md ]; then cp TODO-output.md ~/TODO.md ; fi
	cat ~/TODO.md

#test: | $(shell which vim)
test:
	@#echo $(mkfile_dir)
	@#$(info uname_m=$(uname_m))
	echo $(shell echo ${XDG_CURRENT_DESKTOP})
	@echo "[$(desktop_env)]"
ifneq ($(desktop_env),)
	@echo 'is desktop_env'
else
	@echo 'is NOT desktop_env'
endif

	@echo "mkfile_path: [$(mkfile_path)]"
	@echo "mkfile_dir: [$(mkfile_dir)]"
	@echo "realpath of dir-ssh/config: [$(realpath $(mkfile_dir)ssh/config)]"
	@echo "realpath of dir-/ssh/config: [$(realpath $(mkfile_dir)/ssh/config)]"
	@if [[ $$(dpkg -s some_package_name 2>/dev/null | grep 'Status: install ok installed') ]]; then echo 'true'; fi


#####
#=== configs ===

configs: alacritty bash git nvim ssh termux tmux vim

alacritty: tmux
ifneq ($(uname_o),Android)
	if [[ -d ~/.config/alacritty && ! -d ~/.config/alacritty-makebak ]]; then mv ~/.config/alacritty{,-makebak}; fi
	rm -rf ~/.config/alacritty
	mkdir --parents ~/.config/alacritty
	ln -sf $(realpath $(mkfile_dir)/alacritty/alacritty.yml) ~/.config/alacritty/alacritty.yml
endif  # neq Android

bash:
ifeq ($(uname_o),Android)
	cp bash/bashrc-android ~/.bashrc
else
	@# bashrc
	@if [ -f ~/.bashrc ]; then mv ~/.bashrc ~/.bashrc-makebak; fi
	ln -sf $(realpath bash/bashrc-debian) ~/.bashrc
	@# dircolors (colors 'ls' and such output)
	@if [ -f ~/.dircolors ]; then mv ~/.dircolors ~/.dircolors-makebak; fi
	ln -sf $(realpath bash/dircolors) ~/.dircolors
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


obsidian: ~/.local/share/applications/Obsidian.desktop
ifneq ($(uname_o),Android)
	@echo Obsidian done.
endif

~/.local/share/applications/Obsidian.desktop: ~/apps/obsidian/Obsidian.AppImage
ifneq ($(uname_o),Android)
	@mkdir -p $(HOME)/.local/share/applications
	@ln -sf $(realpath linux-de/home/.local/share/applications/Obsidian.desktop) $(HOME)/.local/share/applications/Obsidian.desktop
endif

~/apps/obsidian/Obsidian.AppImage: ~/apps/obsidian/Obsidian-$(OBSIDIAN_VERSION).AppImage
ifneq ($(uname_o),Android)
	@ln -sf $< $@
endif

~/apps/obsidian/Obsidian-$(OBSIDIAN_VERSION).AppImage:
ifneq ($(uname_o),Android)
	@mkdir -p ~/apps/obsidian
	curl --progress-meter -Lo $@ 'https://github.com/obsidianmd/obsidian-releases/releases/download/v$(OBSIDIAN_VERSION)/Obsidian-$(OBSIDIAN_VERSION).AppImage'
	@chmod u+x $@
endif


redshift: apt-install-redshift ~/.config/redshift.conf

~/.config/redshift.conf:
	@mkdir -p ~/.config
	@if [[ -f ~/.ssh/config && ! -L ~/.ssh/config ]] ; then mv ~/.ssh/config{,-makebak} ; fi
	@ln -sf $(realpath $(mkfile_dir)ssh/config) $@


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


# https://docs.syncthing.net/users/autostart.html?highlight=daemon#linux
# recall default Web GUI address of 127.0.0.1:8384
syncthing: config-syncthing
config-syncthing:
ifneq ($(uname_o),Android)
	@systemctl --user enable syncthing.service
	@systemctl --user start syncthing.service
endif


vim: os-install-vim config-vim
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
	# iptables-restore < ./iptables/some-rule-file
	# There's also the "-T" (table) switch to restore only a named table.


#=== keys ===

keys: key-ssh


key-ssh: ~/.ssh/id_ed25519 ~/.ssh/id_rsa

~/.ssh/id_%:
	ssh-keygen -t %* -C "$(USER)@$(shell hostname)"


#=== installations ===

rust:
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	rustup component add rust-analyzer

os-install-%: apt-update
ifeq ($(strip $(shell which $*)),)
	sudo $(APT_GET) install -y $*
endif


#=== installations : apt ===

apt: apt-install beyondcompare apt-syncthing

apt-install: apt-tier2 beyondcompare

apt-update:
	@#last_update := $$(shell stat -c %Y /var/cache/apt-pkgcache.bin)
	@#now := $$(shell date +%s)
	@#if [ $$(shell $((now - last_update))) ]
	sudo $(APT_GET) update

apt-tier0: apt-update
	sudo $(APT_GET) install -y \
		curl wget \
		screen \
		gpg

apt-tier1: apt-tier0
	sudo $(APT_GET) install -y \
		git lynx unzip \
		tmux \
		vim

apt-tier2: apt-tier1
	sudo $(APT_GET) install -y \
		manpages-dev manpages-posix-dev \
		fzf
ifneq ($(uname_o),Android) # non-smartphone stuff
	sudo $(APT_GET) install -y \
		docker \
		rclone
ifneq ($(DISPLAY),) # desktop stuff
	# byzanz: small screencast creator
	sudo $(APT_GET) install -y \
		flatpak \
		clang cmake \
		libsdl2-dev libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-doc \
		keepass2 xdotool syncthing
endif
endif

#=== installations : redshift ===
apt-install-redshift:
	sudo $(APT_GET) install -y redshift

#=== installations : aws ===
aws: apt-gpg
	gpg --import signatures/aws-cli-team.gpg
	@mkdir -p ./temp
	@curl --no-progress-meter "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig" -o ./temp/awscliv2.zip.sig
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ./temp/awscliv2.zip
	gpg --verify ./temp/awscliv2.zip.sig ./temp/awscliv2.zip
	@unzip -qod ./temp/ ./temp/awscliv2.zip
	sudo ./temp/aws/install -u
	@rm -rf ./temp


#=== installations : beyondcompare ===
# https://www.scootersoftware.com/kb/linux_install
beyondcompare: apt-install-beyondcompare
apt-install-beyondcompare:
ifneq ($(uname_o),Android) # non-Android {
ifneq ($(DISPLAY),)        # 	graphical-only {
ifeq ($(uname_m),x86_64)   # 		64-bit
ifeq ($(shell which bcompare),) # not already installed
	mkdir -p ./temp
ifeq ("$(wildcard ./temp/bc4.deb)","") # only download if we don't have it yet
	curl -L https://www.scootersoftware.com/bcompare-4.4.7.28397_amd64.deb -o ./temp/bc4.deb
endif
	@echo 'e005934a86295611a6041c5cc075dd83508677fd38fbcc8bf69bbe807aec8fa5  ./temp/bc4.deb' | sha256sum --status -c -
	$(SYS_PKG_INSTALL) ./temp/bc4.deb
	rm -rf ./temp
endif                           # already-installed check
else                       # 		32-bit
	@echo WARN: BeyondCompare install not supported on this system/architecture.
endif                      # 		} end 32-or-64-bit
endif                      # 	} end graphical-only
endif                      # } end non-Android

# not really an "apt-*" target; may rename later
# https://docs.syncthing.net/users/autostart.html?highlight=daemon#linux
# recall default Web GUI address of 127.0.0.1:8384
apt-syncthing:
ifneq ($(uname_o),Android) # not-Android {
	systemctl --user enable syncthing.service
	systemctl --user start syncthing.service
ifneq ($(desktop_env),)    # 	only desktop environments (DEs) {
	sudo $(APT_GET) install \
		syncthing-gtk
endif                      # 	} end only-DEs
endif                      # } end non-Android


#=== installations : flatpak ===
apt-install-%: apt-update
	@package := $(subst apt-install-,,$*)
	if [[ $(shell dpkg -s $(package) 2>/dev/null | grep 'Status: install ok installed') ]]; then sudo $(APT_GET) install -y $(package); fi


#=== installations : obsidian ===
obsidian: flatpak-install-flatpak

flatpak-install-%:
	flatpak install --user -y $*


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
sshdmfa:
ifneq ($(uname_o),Android)
	@# For some reason ntp has dependencies on a bunch of pop-os desktop packages?
	@#sudo apt-get install libpam-google-authenticator ntp
	sudo apt-get install libpam-google-authenticator
	@echo "Add this line to the top of the file we're about to edit:"
	@echo "auth [success=done new_authtok_reqd=done default=die] pam_google_authenticator.so nullok"
	@read -p "Press Enter once you've copied the above line to add it to the top of the file we're about to edit..." < /dev/tty
	sudo vim /etc/pam.d/sshd
	@echo "If you're not on the user which will be used for login, break out of this next command."
	google-authenticator -l "chris@$(shell hostname)"
	sudo systemctl restart ssh
endif

sshd:
ifneq ($(uname_o),Android)
	sudo apt-get install openssh-server
	@# if regular file (not a symlink; that'd be -L), make a backup first
	if [[ -f /etc/ssh/sshd_config && ! -L /etc/ssh/sshd_config ]] ; then sudo mv /etc/ssh/sshd_config{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/sshd_config) /etc/ssh/sshd_config
	if [[ -f /etc/pam.d/sshd && ! -L /etc/pam.d/sshd ]] ; then sudo mv /etc/pam.d/sshd{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/pam.d/sshd) /etc/pam.d/sshd
	@# per-user
	if [[ -f ~/.ssh/authorized_keys && ! -L ~/.ssh/authorized_keys ]] ; then sudo mv ~/.ssh/authorized_keys{,-makebak}; fi
	sudo ln -sf $(realpath $(mkfile_dir)ssh/authorized_keys) ~/.ssh/authorized_keys
	sudo systemctl restart ssh
	@echo "!! Don't forget to make sshdmfa !!"
endif


#=== Linux desktop environment things ===
gnome:
	cat $(realpath $(mkfile_dir)/linux-de/dconf.conf) | dconf load


#=== System76-specific things ===
system76: ~/power-charge-thresholds.sh
	ln -sf $(realpath $(mkfile_dir)system76/power-charge-thresholds.sh) ~/power-charge-thresholds.sh

