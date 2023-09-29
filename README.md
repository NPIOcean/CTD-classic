# CTD data processing, *classic* method

*Originally written by Yannick Kern. Procedure developed together with Paul Dodd.*

This repository contains documentation and code for the *classic* CTD processing procedure at NPI. 

The procedure, described [here](workflow.md), involves:

- Creating dataset-specific configuration files in the *SBE Data Processing* software.
- Running SBE processing on a CTD dataset using Windows batch scripts.
- Quality control of the data in Matlab. 
- Conversion to CF-formatted NetCDF using the *NetCDF-creator* tool.


**NOTE:**

An alternative procedure, using Python and not reliant on proprietary software, is under development. This alternative procedure is highly experimental, and **the *classic* procedure is currently the recommended way of processing CTD data**.


## Instructions

All the relevant datasets can be found on `data.npolar.no` using: 

```
https://data.npolar.no/home/search?q=CTD%20profiles%20from%20NPI%20cruise%20FS%20paul
```

The project files can be found on NPDATA: 

```
npdata/project/Fram_strait/SOURCE/CTD
```

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
