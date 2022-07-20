#!/bin/sh

echo "Install idx-tools to $HOME/bin"

chmod +x R/idxDaily.R
chmod +x R/install-deps.R
chmod +x Bash/update-data.sh
chmod +x Bash/update-csv.sh
chmod +x Bash/update-idx30.sh

ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily
ln -sf `pwd`/R/install-deps.R $HOME/bin/idx-deps
ln -sf `pwd`/Bash/update-data.sh $HOME/bin/idxdata-update
ln -sf `pwd`/Bash/update-csv.sh $HOME/bin/csvdata-update
ln -sf `pwd`/Bash/update-idx30.sh $HOME/bin/idx30data-update

idx-deps
if [ ! -d "$HOME/.idx-data" ]
then
 git clone --depth=1 https://github.com/idx-repo/idx-data.git ~/.idx-data
else
 idxdata-update
fi
