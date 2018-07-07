.PHONY: all vim git


all: vim git


vim:
	rm -rf ~/.vim
	rm -f ~/.vimrc
	ln -s vim ~/.vim
	ln vim/vimrc ~/.vimrc


git:
	rm -f ~/.gitconfig
	ln git/gitconfig ~/.gitconfig

