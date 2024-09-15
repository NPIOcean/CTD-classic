# CTD data processing, *classic* method

*Originally written by Yannick Kern. Procedure developed together with Paul Dodd.*

This repository contains documentation and code for the *classic* CTD processing procedure at NPI. 

The procedure, described [here](workflow.md), involves:

- Creating dataset-specific configuration files in the *SBE Data Processing* software.
- Running SBE processing on a CTD dataset using Windows batch scripts.

  **NOTE:**

This `with kval` branch let's you chose from here if you want to 
- 
  - Do quality control of the data in Matlab.
  - Conversion to CF-formatted NetCDF using the *NetCDF-creator* tool.

  or
  -
  -  use python-based [`kval`](https://github.com/NPIOcean/kval) functions for this.
  -  This alternative procedure is highly experimental, and uses the **iC3_field_school_2024 dataset as testbed and template**.
  -  The `with_lval`procedure is not yet documented in the [workflow](workflow.md) documentation and the below comments in this file.




## Instructions

All the relevant datasets can be found on the iC3 field school teams.

### List of script file extensions

- Matlab `.m` files: convert instrument data `.cvn` into Matlab `.mat` arrays/binaries
- `.json` config files for [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator) software to convert Matlab `.mat` into NetCDF4 `.nc` files
- batch `.bat` files that start Seabird sbebatch processing terminal/software

### Workflow

Described in [workflow.md](workflow.md)

Requires:

- [SBE Data Processing](https://www.seabird.com/software)
  - __NOTE__: Mac and Windows version currently only at: `forskning/Yannick/NetCDF_Creator/`
- [Matlab](https://se.mathworks.com//)
- [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator)

### Additional info

- [Variable name overview](https://docs.google.com/spreadsheets/d/1RBGrF3EpTsY2bSWDIT-T6CzXqMzAzaFxAbrmaeaw6wE/edit#gid=0)
