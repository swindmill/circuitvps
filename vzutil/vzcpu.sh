#!/bin/bash

for VZ in $(vzlist -H -o veid); do echo CPU usage for VEID $VZ: && /root/stuff/vzutil/vzprocps/bin/vzps h -o %cpu -E $VZ | awk '{sum += $1} END {print sum}'; done
