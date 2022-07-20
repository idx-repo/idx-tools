#!/bin/bash
for i in $(cut -d "," -f 1 $HOME/.idx-data/Index/IDX30.csv | tr -d '"' | tail -n +2)
do
 echo "Update $i"
 idxDaily -e $i -o "$i.csv"
done
