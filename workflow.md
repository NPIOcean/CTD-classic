# Worfklow
General processing chain:
1. Windows SBE processing: `cruiseTag/scripts/*.bat`
2. Matlab processing:
    1. `cruiseTag/scripts/cnv2mat.m`
    2. `cruiseTag/scripts/btl2mat.m`
    3. `cruiseTag/scripts/combine_mat.m`
3. NetCDF conversion with [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator) using the config file: `cruiseTag/netcdf/cruiseTag.json`
  - usually the work directory of the NetCDF-Creator software is set to the parent folder of the `cruiseTag`


## Processing setup
Requires Windows OS.

### Directory structure
Duplicate the template folder `new_cruise_template` (`/npdata/project/Fram_strait/SOURCE/CTD/new_cruise_template`) and rename to desired `cruiseTag` name (e.g. `fs_YYYY`). Keep in same directory as `default_psa` and `default_scripts`. This is because batch files will load processing scripts from those folders. If starting in a new work directory make sure to take a copy of those two directories as well.


### Init structure
- copy all CTD files besides `.cnv` and `.btl` to the `raw` folder (`.bl`|`.hdr`|`.hex`|`.XMLCON`)
- copy one `.XMLCON` file per CTD setting to the `setup` folder, meaning that if the setup of the CTD never changed then one `.XMLCON` file (e.g. of the first station) would be enough for the whole cruise
- modify that `.XMLCON` file for CDOM using
  - Dark output=0
  - Scale factor=1


### A) Initial setup for SBE batch processing
Manually run SBE processing once in order to update the `.psa` files located in `cruiseTag\setup\psa_general\`.

#### 1 Data Conversion
- Program setup file: `cruiseTag\setup\psa_general\DatCnv.psa`
- Instrument setup file (modified version): `\cruiseTag\setup\STA0120_modified.XMLCON`
- Input directory: `cruiseTag\raw`
- Input files (first station is enough): `Sta0120.hex`
- Output directory: `\cruiseTag\proc`

#### 2 Filter
- Program setup file: `cruiseTag\setup\psa_general\Filter.psa`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.cnv`
- Output directory: `\cruiseTag\proc`

#### 4 Cell Thermal Mass
- Program setup file: `cruiseTag\setup\psa_general\CellTM.psa`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.cnv`
- Output directory: `\cruiseTag\proc`

#### 5 Loop Edit
- Program setup file: `cruiseTag\setup\psa_general\LoopEdit.psa`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.cnv`
- Output directory: `\cruiseTag\proc`

#### 6 Derive
- Program setup file: `cruiseTag\setup\psa_general\Derive.psa`
- Instrument setup file (modified version): `cruiseTag\setup\STA0120_modified.XMLCON`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.cnv`
- Output directory: `\cruiseTag\proc`

#### 8 Bin Average
- Program setup file: `cruiseTag\setup\psa_general\BinAvg.psa`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.cnv`
- Output directory: `\cruiseTag\proc`
- Name append: `_bin`

#### 9 Bottle Summary
- Program setup file: `cruiseTag\setup\psa_general\BottleSum.psa`
- Instrument setup file (modified version): `\cruiseTag\setup\STA0120_modified.XMLCON`
- Input directory: `cruiseTag\proc`
- Input files (first station is enough): `Sta0120.ros`
- Output directory: `\cruiseTag\proc`

#### 13 Window Filter
Run all three filter `.psa` once with one station to update them.
- `cruiseTag\setup\psa_general\W_Filter_short.psa` (on `.cnv` file)
- `cruiseTag\setup\psa_general\W_Filter_long.psa` (on `_bin.cnv` file)
- `cruiseTag\setup\psa_general\W_Filter_final_smooth.psa` (on `_bin.cnv` file)
This will for this manual run only overwrite files but the automatic processing will produce an extra version at this point ending on `_bin_cdom.cnv`


### B) Setup automated SBE batch processing
Referring to `script\stnA-stnB_call_processing.bat`. See description in the file for further information on how to specify.

### C) Additional steps
#### Different instrument setups
In case the CTD setup changes multiple times during the cruise - i.e. sensors get swapped, added or removed. Then the whole process above has to be done again for each specific range of same stations (same CTD setup).
- duplicate the `psa_general` folder and for instance name it after the station range
- get one `.XMLCON` file for that station range and again modify CDOM
- run all the steps one time manually with SBE processing to adjust the `.psa` files in the duplicated folder
- duplicate the `.bat` file and adjust it to that station range. This will lead to multiple `.bat` files e.g. the first for stations 1-10, second 11-20 and last for 20-99999.

After setting this up once all `.bat` files can be double clicked to run over the specific station ranges again for reprocessing or if data was updated for instance.


#### Different CTDs
In case different CTDs are used on one cruise, for instance one 12 and one 24 rosette version.
Make a raw folder each and treat both as separate sensor setups. Follow procedure like above but instead of having one "raw" folder it is now two. Move the raw files into the specific folders and adjust the batch scripts of each setting to refer to the right raw folder.



## Matlab
Last step is to read the cnv files into Matlab and export them as `.mat` files. 


### CTD data
Using `script/cnv2mat.m`
- follow instructions in script
- for each station range check a `.cnv` file and update the reading function in the end of the script for each station range.


### Bottle data
Using `script/btl2mat.m`
- follow instructions in script
- for each station range check a `.cnv` file and update the reading function in the end of the script for each station range.


### Merge dataset and add results
Using `script/combine_mat.m`
- adjust variables in script as needed
The script does:
- merge the CTD sensor and bottle data into one Matlab `.mat` file 
- include CDOM result
- remove moonpool bad data
- adds further necessary variables for NetCDF conversion


## NetCDF-Creator
Uses the `.json` config file in the `netcdf` directory. Use one from a previous year as template and adjust it to the needs.
- load the datafile `mat/all_combined_published.mat`
- save in `netcdf/bin`, `netcdf/bot` or `netcdf/carbon_chemistry` depending on what is converted
