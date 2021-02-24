#!/bin/bash
echo
echo "Simple Reflector por SimplyArch"
echo
reflector --verbose --protocol http --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
