#!/usr/bin/bash

echo '-- Profiles list:'
sudo system76-power charge-thresholds --list-profiles

echo '-- Currently using:'
sudo system76-power charge-thresholds

PS3='Select a charge threshold profile:'
options=(' 60% - Maximum battery lifespan' ' 90% - Balanced' '100% - Full charge' 'q')
select opt in "${options[@]}"; do
    case $opt in
        '1')
            sudo system76-power charge-thresholds --profile max_lifespan
            break
            ;;
        '2')
            sudo system76-power charge-thresholds --profile balanced
            break
            ;;
        '3')
            sudo system76-power charge-thresholds --profile full_charge
            break
            ;;
        *)
            break
            ;;
    esac
done

echo '-- Rem:'
echo 'sudo system76-power charge-thresholds --profile foo'

