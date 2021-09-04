#!/bin/sh

echo "Install idx-tools to $HOME/bin"

chmod +x R/idxDaily.R

ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily
