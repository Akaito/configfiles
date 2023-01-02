#!/usr/bin/bash

sudo system76-power charge-thresholds --list-profiles
echo '--Was:'
sudo system76-power charge-thresholds
echo '--Is now:'
sudo system76-power charge-thresholds --profile balanced

echo '--Rem:'
echo 'sudo system76-power charge-thresholds --profile foo'

