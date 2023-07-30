# This is oceanography CTD dataset production repository

All the relevant dataset can be found using: 
```
https://data.npolar.no/home/search?q=CTD%20profiles%20from%20NPI%20cruise%20FS%20paul
```

The project files can be found on NPDATA: 
```
npdata/project/Fram_strait/SOURCE/CTD
```

## List of script file extensions
- Matlab `.m` files: convert instrument data `.cvn` into Matlab `.mat` arrays/binaries
- `.json` config files for [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator) software to convert Matlab `.mat` into NetCDF4 `.nc` files
- batch `.bat` files that start Seabird sbebatch processing terminal/software

## Workflow
Described in [workflow.md](workflow.md)

Requires:
- [SBE Data Processing](https://www.seabird.com/software)
  - __NOTE__: Mac and Windows version currently only at: `forskning/Yannick/NetCDF_Creator/`
- [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator)

## Additional info
- [Variable name overview](https://docs.google.com/spreadsheets/d/1RBGrF3EpTsY2bSWDIT-T6CzXqMzAzaFxAbrmaeaw6wE/edit#gid=0)
