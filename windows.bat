@ECHO OFF
setlocal
echo "REM: Run this as admin."

REM Alacritty
choice /M "Config alacritty?"
if /I "%ERRORLEVEL%" neq "1" goto no_alacritty
echo "Configuring alacritty..."
del "%APPDATA%\alacritty"
mkdir "%APPDATA%\alacritty"
mklink /H "%APPDATA%\alacritty\alacritty.yml" alacritty\alacritty-windows.yml
:no_alacritty

REM Git
choice /M "Config git?"
if /I "%ERRORLEVEL%" neq "1" goto no_git
echo "Configuring git..."
del "%USERPROFILE%\.gitconfig"
mklink /H "%USERPROFILE%\.gitconfig" git\gitconfig
:no_git

REM Vim
choice /M "Config vim?"
if /I "%ERRORLEVEL%" neq "1" goto no_vim
echo "Configuring vim..."
mklink /H "%USERPROFILE%\.vimrc" vim\vimrc
mklink /J "%USERPROFILE%\.vim" vim
:no_vim

endlocal

