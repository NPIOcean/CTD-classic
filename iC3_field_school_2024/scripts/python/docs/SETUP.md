# Setup

### 1. **Clone the repository to your system**



### 2. **Populate with source files**

When you have data files, or as you get them:

- Put the `.cnv` files you consider "final" in `data/source/cnv/`. This will typically probably be files a la `StaXXXX_bin_cdom.cnv`
- Put any unbinned `.cnv` files in  `data/source/cnv_unbinned/` (typically `XXX.cnv` or similar).
- Put `.btl` files in `data/source/cnv/`.
- Put the *salts* (salinometer measurements) and *ctd* (CTD log) excel sheets (`.xls`) in `data/source/salinometer/`

### 3. **Install and activate the conda environment**

- Open Miniforge
- Navigate to the root folder of this repository
- Type `mamba env create -f fs24_env.yml`
- This should install a new mamba environment with the requirements specified in the file.
    - This includes (a specific version of) the [`kval`](https://github.com/NPIOcean/kval) library.



### 4. Run the notebooks

- From the root folder of the repository, run `jupyter lab`
    - This should open Jupyter lab in your browser.
- Navigate into the `notebooks` folder and open any notebooks you want to run.
- :warning: **Make sure to set the kernel to the `fs24` environment!**
    - Go to `Kernel -> Switch Kernel` or click the current kernel on the top right of the notebook.
    - Choose something like `Python [conda env:fs24]*`

- You should now be able to run cells of the notebook