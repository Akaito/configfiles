@ECHO OFF
echo "REM: Run this as admin."

REM Alacritty
mklink /J "%APPDATA%\alacritty" alacritty

REM Vim
mklink /H "%USERPROFILE%\.vimrc" vim\vimrc
mklink /J "%USERPROFILE%\.vim" vim

