# Overview 

This repo contains some relatively basic functionality for working with CTD data in Python. It relies on the functionality in the [`kval`](https://github.com/NPIOcean/kval) library (formerly `oceanograpy`). `kval` is under development and somewhat in the middle of a refactoring, so do not expect everything to work seamlessly..

### Mamba environment / `yml` file

This file contains specification for building a mamba environment with `kval` installed (see [Setup](SETUP.md)).

If you want to be able to follow updates of `kval` (of which there are likely to be a few in the coming weeks), you can:

- Clone the `kval` repo from Github.
- Navigate to the root folder.
- Actibvate the working mamba environment and install `kval` install using `pip install -e .`
- The `-e` flag means that if you `git pull` the `kval` repo, changes in the source code will be included when you `import` modules from `kval`. 

## Scripts

### `notebooks/inspect`

##### `Underway quick look at files.ipynb`

Quick-looks at CTD dataset (maps, contour and profile plots, etc)

##### `Inspect single .cnv.ipynb`

Contains some functions for looking at single `.cnv`s. Useful for diagnosis etc.

#### `Compare salinometer and CTD salinity.ipynb`

Compare CTD (`btl` files) with salinometer values (from excel files). May or may not work depending on whether the format of the excel files has changed.. 

### `notebooks/process`

##### `Convert to netCDF.ipynb`

Parse the CTD profile data from `cnv`s, join together to a single file and save as netcdf.

##### `Editing.ipynb`

Load the netCDF and apply various editing functions..

