@ECHO OFF
setlocal
REM echo "REM: Run this as admin... Maybe?"

:: Alacritty
choice /M "Config alacritty?"
if /I "%ERRORLEVEL%" neq "1" goto no_alacritty
echo Configuring alacritty...
del "%APPDATA%\alacritty"
mkdir "%APPDATA%\alacritty"
mklink /H "%APPDATA%\alacritty\alacritty.yml" alacritty\alacritty.windows.yml
:no_alacritty

:: Git
choice /M "Config git?"
if /I "%ERRORLEVEL%" neq "1" goto no_git
echo Configuring git...
del "%USERPROFILE%\.gitconfig"
mklink /H "%USERPROFILE%\.gitconfig" git\gitconfig
:no_git

:: Vim
choice /M "Config vim?"
if /I "%ERRORLEVEL%" neq "1" goto no_vim
echo Configuring vim...
rd /S /Q "%USERPROFILE%\vimfiles"
del "%USERPROFILE%\.vimrc"
mklink /J "%USERPROFILE%\vimfiles" vim
mklink /H "%USERPROFILE%\.vimrc" vim\vimrc
echo   Doing Plug updates...
vim -c PlugUpgrade -c PlugUpdate -c qa
:no_vim

endlocal

