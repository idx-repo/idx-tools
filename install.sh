#!/bin/sh

echo "Install idx-tools to $HOME/bin"

chmod +x R/idxDaily.R
chmod +x Bash/update-data.sh

ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily
ln -sf `pwd`/Bash/update-data.sh $HOME/bin/idxdata-update

if [ ! -d "$HOME/R/x86_64-suse-linux-gnu-library/4.1/optparse" ]
then
 Rscript -e 'install.packages("optparse", repos="http://cran.r-project.org")'
fi
if [ ! -d "$HOME/R/x86_64-suse-linux-gnu-library/4.1/quantmod" ]
then
 Rscript -e 'install.packages("quantmod", repos="http://cran.r-project.org")'
fi
if [ ! -d "$HOME/.idx-data" ]
then
 git clone --depth=1 https://github.com/idx-repo/idx-data.git ~/.idx-data
else
 idxdata-update
fi
