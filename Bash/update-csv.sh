#!/bin/bash
for i in $(ls $HOME/.idx-data/Daily_Price/)
do
 echo "Update $(basename $i .csv)"
 idxDaily -e $(basename $i .csv) -o $i
done
