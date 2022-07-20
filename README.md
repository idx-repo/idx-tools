# idx-tools

Our IDX Tools

## Tools List

- Bash/update-data.sh -> sync idx-repo/idx-data repository.
- Bash/update-csv.sh -> update all emiten csv (CODE.csv) on $(pwd).
- Bash/update-idx30.sh -> update all emiten on IDX30.
- R/idxDaily.R -> download emiten CODE.
- R/install-deps.R -> Install R package dependencies.

## Instalation

```
ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily
ln -sf `pwd`/R/install-deps.R $HOME/bin/idx-deps
ln -sf `pwd`/Bash/update-data.sh $HOME/bin/idxdata-update
ln -sf `pwd`/Bash/update-csv.sh $HOME/bin/csvdata-update
```

Or just run `sh install.sh`.

### Deinstallation

Just run `sh remove.sh`.


