#!/bin/sh

echo "Install idx-tools to $HOME/bin"

mkdir -p "$HOME/bin"

chmod +x R/idxDaily.R
chmod +x R/install-deps.R
chmod +x R/plotDaily.R
chmod +x Bash/update-data.sh
chmod +x Bash/update-csv.sh
chmod +x Bash/update-index.sh
chmod +x Bash/update-idx30.sh
chmod +x Bash/update-lq45.sh
chmod +x Bash/update-idx80.sh
chmod +x Bash/update-issi.sh
chmod +x Bash/update-idxic.sh

ln -sf "$PWD/R/idxDaily.R" "$HOME/bin/idxDaily"
ln -sf "$PWD/R/install-deps.R" "$HOME/bin/idx-deps"
ln -sf "$PWD/R/plotDaily.R" "$HOME/bin/plotDaily"
ln -sf "$PWD/Bash/update-data.sh" "$HOME/bin/idxdata-update"
ln -sf "$PWD/Bash/update-csv.sh" "$HOME/bin/csvdata-update"
ln -sf "$PWD/Bash/update-index.sh" "$HOME/bin/idxindex-update"
ln -sf "$PWD/Bash/update-idx30.sh" "$HOME/bin/idx30data-update"
ln -sf "$PWD/Bash/update-lq45.sh" "$HOME/bin/lq45data-update"
ln -sf "$PWD/Bash/update-idx80.sh" "$HOME/bin/idx80data-update"
ln -sf "$PWD/Bash/update-issi.sh" "$HOME/bin/issidata-update"
ln -sf "$PWD/Bash/update-idxic.sh" "$HOME/bin/idxic-update"

idx-deps
if [ ! -d "$HOME/.idx-data" ]
then
 git clone --depth=1 https://github.com/idx-repo/idx-data.git "$HOME/.idx-data"
else
 idxdata-update
fi
