# This is oceanography CTD dataset production repository

All the relevant dataset can be found using: 
```
https://data.npolar.no/home/search?q=CTD%20profiles%20from%20NPI%20cruise%20FS%20paul
```

The project files can be found on NPDATA: 
```
/run/user/1000/gvfs/smb-share:server=npdata,share=project/Fram_strait/SOURCE/CTD/
```

## List of script file extensions
- Matlab `.m` files: convert instrument data `.cvn` into Matlab `.mat` arrays/binaries
- `.json` config files for NetCDF-Creator software to convert Matlab `.mat` into NetCDF4 `.nc` files
- batch `.bat` files that start Seabird sbebatch processing terminal/software

## Workflow
Described in [workflow.md](workflow.md)
