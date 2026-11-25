# idx-tools

[![CI](https://github.com/asepkcakep/idx-tools/actions/workflows/ci.yml/badge.svg)](https://github.com/asepkcakep/idx-tools/actions/workflows/ci.yml)

Tools for updating and analyzing Indonesia Stock Exchange (IDX) historical daily prices.

## Tools List

- `Bash/update-data.sh` (`idxdata-update`): Sync the `idx-repo/idx-data` git repository.
- `Bash/update-csv.sh` (`csvdata-update`): Update emiten daily price CSV files in bulk with limit/dry-run options.
- `Bash/update-index.sh` (`idxindex-update`): Unified tool to update emiten by index (e.g. `IDX30`, `LQ45`, `IDX80`, `ISSI`), IDX-IC sector (`-c <sector>`), or custom file list (`-f <file>`).
- `Bash/update-idx30.sh` (`idx30data-update`): Shortcut for updating all IDX30 constituents.
- `Bash/update-lq45.sh` (`lq45data-update`): Shortcut for updating all LQ45 constituents.
- `Bash/update-idx80.sh` (`idx80data-update`): Shortcut for updating all IDX80 constituents.
- `Bash/update-issi.sh` (`issidata-update`): Shortcut for updating all ISSI constituents.
- `Bash/update-idxic.sh` (`idxic-update`): Shortcut for updating emiten belonging to an IDX-IC sector code.
- `R/idxDaily.R` (`idxDaily`): Download daily OHLCV price data for an emiten ticker.
- `R/plotDaily.R` (`plotDaily`): Generate technical chart (candlestick, MACD, RSI, Volume, Bollinger Bands).
- `R/install-deps.R` (`idx-deps`): Install required R package dependencies (`optparse`, `quantmod`).

## Installation

```bash
sh install.sh
```

Or manually create symlinks in `$HOME/bin`:

```bash
mkdir -p $HOME/bin
ln -sf `pwd`/R/idxDaily.R $HOME/bin/idxDaily
ln -sf `pwd`/R/install-deps.R $HOME/bin/idx-deps
ln -sf `pwd`/R/plotDaily.R $HOME/bin/plotDaily
ln -sf `pwd`/Bash/update-data.sh $HOME/bin/idxdata-update
ln -sf `pwd`/Bash/update-csv.sh $HOME/bin/csvdata-update
ln -sf `pwd`/Bash/update-index.sh $HOME/bin/idxindex-update
ln -sf `pwd`/Bash/update-idx30.sh $HOME/bin/idx30data-update
ln -sf `pwd`/Bash/update-lq45.sh $HOME/bin/lq45data-update
ln -sf `pwd`/Bash/update-idx80.sh $HOME/bin/idx80data-update
ln -sf `pwd`/Bash/update-issi.sh $HOME/bin/issidata-update
ln -sf `pwd`/Bash/update-idxic.sh $HOME/bin/idxic-update
```

### Deinstallation

```bash
sh remove.sh
```

## Usage & Arguments

All scripts feature robust command-line argument parsing supporting both `-o value` and `--option=value` syntax, dry-run simulation, and help flags (`-h` / `--help`).

### 1. Update Index Constituents (`idxindex-update`)

```bash
# Update IDX30 constituents with 1 second lag between requests
idxindex-update IDX30 --lag=1

# Update LQ45 into a specific folder with verbose logging and 0.5s delay
idxindex-update -i LQ45 -o ./my-data -w 0.5 --verbose

# Update IDX-IC sector A
idxindex-update -c A
# or using idxic-update shortcut:
idxic-update A

# Simulate / Dry run without network requests
idxindex-update -i IDX80 --dry-run

# Custom file list
idxindex-update -f /path/to/custom-list.csv
```

### 2. Update All CSVs (`csvdata-update`)

```bash
# Update all CSVs in ~/.idx-data/Daily_Price
csvdata-update

# Batch update only 10 files
csvdata-update --limit=10 --verbose

# Dry run simulation
csvdata-update -n
```

### 3. Sync IDX Data Repository (`idxdata-update`)

```bash
# Pull latest changes
idxdata-update

# Pull silently from a custom directory
idxdata-update -d /path/to/.idx-data --quiet
```

### 4. Single Emiten Fetch & Plot (`idxDaily`, `plotDaily`)

```bash
# Download ticker data (e.g. BBCA)
idxDaily -e BBCA -o BBCA.csv --verbose

# Generate chart for past 365 days
plotDaily -e BBCA -o BBCA.png -d 365
```

## Running Tests

A comprehensive test suite is provided in `tests/`:

```bash
# Run all test suites
make test
# or directly:
bash tests/run_tests.sh

# Run syntax/lint checks
make lint
```

