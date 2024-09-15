# Setup

### 1. **Clone the `CTD-classic` repository to your system, selectign the `with_kval`branch**



### 2. **Populate with source files**

When you have data files, or as you get them:

- follow the directory structure from the `template`directory to bulid your project directory, `iC3_field_school_2024`in this example
- Put the `.cnv` files you consider "final" in `cnv/`. This will typically probably be files a la `StaXXXX_bin_cdom.cnv`
- Put also the unbinned `.cnv` files in  `cnv/` (typically `XXX.cnv` or similar).
- Put `.hex` and other raw data files in `raw/`.
- We did not take salinity samples, but if you hat, put the *salts* (salinometer measurements) and *ctd* (CTD log) excel sheets (`.xls`) in `data/source/salinometer/`

### 3. **Install and activate the conda environment**

- Open Miniforge (installit from here: https://github.com/conda-forge/miniforge)
- Navigate to the root folder of this repository
- Type `mamba env create -f kval_ctd_env.yml`
- This should install a new mamba environment with the requirements specified in the file.
    - This includes (a specific version of) the [`kval`](https://github.com/NPIOcean/kval) library.
- activate this environment by typing `conda activate kval_ctd`



### 4. Run the notebooks

- From the `python` folder of the repository, run `jupyter lab`
    - This should open Jupyter lab in your browser.
- Navigate into the `notebooks` folder and open any notebooks you want to run.
- :warning: **Make sure to set the kernel to the `kval_ctd` environment!**
    - Go to `Kernel -> Switch Kernel` or click the current kernel on the top right of the notebook.
    - Choose something like `Python [conda env:kval_ctd]*`

- You should now be able to run cells of the notebook
- Start by reproducing steps in the `underway quicklook at files` notebook, then try `Editing` the profiles
