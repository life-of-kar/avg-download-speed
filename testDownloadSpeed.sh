#!/bin/bash
# Script to check avg download speed which are listed in mylist.txt
# The text file contains links to various test files from different hosts.
# One link per line with location and host.
# link<space>location<space>host

date | tee -a $HOME/bench.log

infile=$1
i=1
while read -r line
do
    printf "Line %3d: %s\n" $i "$line" | tee -a $HOME/bench.log
    arr=($line)
        node_server=$( wget -4 -O /dev/null ${arr[0]} 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
        printf "Avg speed: $node_server " | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log
    let i=i+1
done<$infile


