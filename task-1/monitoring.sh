#!/bin/bash

TO="user@trbhi.com"
SUBJECT="ATTENTION: Important Metrics of the system $(hostname) at $(date)"

###Calculate CPU Usage of the system####
cpuuse=$(cat /proc/loadavg | awk '{print $2}')

###Capturing the Network Usage###
network = $(ip -s -h link |awk '{print $1,$2,$3}')

###Compute the disk usage on each partition###
df -Ph | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5,$1 }' | while read output;
do
  echo $output

  used=$(echo $output | awk '{print $1}' | sed s/%//g)

  partition=$(echo $output | awk '{print $2}')

  echo "The partition \"$partition\" on $(hostname) has used $used% at $(date) with the Current Usage of $cpuuse% and the Network flow $network" | mail -s "$SUBJECT" "$TO"
  done
