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

REM Vim
choice /M "Config vim?"
if /I "%ERRORLEVEL%" neq "1" goto no_vim
echo "Configuring vim..."
REM mklink /H "%USERPROFILE%\.vimrc" vim\vimrc
REM mklink /J "%USERPROFILE%\.vim" vim
:no_vim

endlocal

