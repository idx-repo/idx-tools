#!/bin/sh

echo "Install idx-tools to $HOME/bin"

chmod +x R/idxDaily.R

rm $HOME/bin/idxDaily
ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily

Rscript -e 'install.packages("optparse", repos="http://cran.r-project.org")'
Rscript -e 'install.packages("quantmod", repos="http://cran.r-project.org")'
