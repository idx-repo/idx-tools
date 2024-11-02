#!/bin/bash
for i in $(cut -d "|" -f 1 $HOME/.idx-data/IDX-IC/$1.tsv | tr -d '"' | tail -n +2 | awk '{print $2}')
do
 echo "Update $i"
 idxDaily -e $i -o "$i.csv"
done
