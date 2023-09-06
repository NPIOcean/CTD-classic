# Worfklow

General processing chain:

1. Windows SBE processing: `template/scripts/*.bat`
2. Matlab processing:
   1. `template/scripts/cnv2mat.m`
   2. `template/scripts/btl2mat.m`
   3. `template/scripts/combine_mat.m`
3. NetCDF conversion with [NetCDF-Creator](https://gitlab.com/npolar/netcdf-creator) using the config file: `template/netcdf/template.json`
   - usually the work directory of the NetCDF-Creator software is set to the parent folder of `template`

## Processing setup

Requires Windows OS.

### A) Directory structure

Duplicate the template folder `template` and rename to desired `cruiseTag` name (e.g. `fs_YYYY`). Keep in same directory as `default_psa` and `default_scripts`. This is because batch files will load processing scripts from those folders using relative pathing. If starting in a new work directory make sure to take a copy of those two directories as well.

### B) Init structure

- copy all CTD files besides `.cnv` and `.btl` to the `raw` folder (`.bl`|`.hdr`|`.hex`|`.XMLCON`)
- copy one `.XMLCON` file per CTD setting to the `setup` folder, meaning that if the setup of the CTD never changed then one `.XMLCON` file (e.g. of the first station) would be enough for the whole cruise
- (if relevant) modify that `.XMLCON` file for CDOM using
  - Dark output=0
  - Scale factor=1

### C) Initial setup for SBE batch processing

Manually run SBE processing once in order to update the `.psa` files located in `template\setup\psa_general\`. For the example files on the repo here a duplicate was used (`template\setup\psa_test\`) to keep the default `.psa` files untouched.

#### 1 Data Conversion

- Program setup file: `template\setup\psa_general\DatCnv.psa`
- Instrument setup file: `\template\setup\Sta0001.XMLCON`
- Input directory: `template\raw`
- Input files (first station is enough): `Sta0001.hex`
- Output directory: `\template\proc`

#### 2 Filter

- Program setup file: `template\setup\psa_general\Filter.psa`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\template\proc`

#### 4 Cell Thermal Mass

- Program setup file: `template\setup\psa_general\CellTM.psa`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\template\proc`

#### 5 Loop Edit

- Program setup file: `template\setup\psa_general\LoopEdit.psa`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\template\proc`

#### 6 Derive

- Program setup file: `template\setup\psa_general\Derive.psa`
- Instrument setup file: `template\setup\Sta0001.XMLCON`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\template\proc`

#### 8 Bin Average

- Program setup file: `template\setup\psa_general\BinAvg.psa`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\template\proc`
- Name append: `_bin`

#### 9 Bottle Summary

- Program setup file: `template\setup\psa_general\BottleSum.psa`
- Instrument setup file (modified version): `template\setup\Sta0001.XMLCON`
- Input directory: `template\proc`
- Input files (first station is enough): `Sta0001.ros`
- Output directory: `\template\proc`

#### 13 Window Filter

Run all three filter `.psa` once with one station to update them.

- `template\setup\psa_general\W_Filter_short.psa` (on `.cnv` file)
- `template\setup\psa_general\W_Filter_long.psa` (on `_bin.cnv` file)
- `template\setup\psa_general\W_Filter_final_smooth.psa` (on `_bin.cnv` file)
  This will for this manual run only overwrite files but the automatic processing later will produce an extra version at this point ending on `_bin_cdom.cnv`

### D) Setup automated SBE batch processing

Referring to `template\script\stnA-stnB_call_processing.bat`. See description in the file for further information on how to set up.

### E) Additional steps

#### Different instrument setups

In case the CTD setup changes multiple times during the cruise - i.e. sensors get swapped, added or removed. Then the whole process above (section C and D) has to be done again for each specific range of same stations (same CTD setup).

- duplicate the `psa_general` folder and for instance name it after the station range
- get one `.XMLCON` file for that station range and again modify CDOM if necessary
- run all the steps one time manually with SBE processing to adjust the `.psa` files in the duplicated folder
- duplicate the `.bat` file and adjust it to that station range. This will lead to multiple `.bat` files e.g. the first for stations 1-10, second 11-20 and last for 20-99999.

After setting this up once, all `.bat` files can be double clicked to run over the specific station ranges again for reprocessing or if data was updated for instance.

#### Different CTDs

In case different CTDs are used on one cruise, for instance one 12 and one 24 rosette version.
Create a second `raw` folder so there is one each (e.g. `raw` and `raw_12`) and treat both as separate sensor setups. Follow the procedure like above (section C and D) for each setup separately. Move the raw files into the specific folders and adjust the batch scripts of each setting to refer to the right raw folder. The output folder can still be the same `proc` directory.

## Matlab

Last step is to read the `.cnv` files into Matlab and export them as `.mat` files. 

#### CTD data

Using `template/script/cnv2mat.m`

- follow instructions in script
- for each stations range of the same setup check a `.cnv` file and update the reading function in the end of the script for each station range.

#### Bottle data

Using `template/script/btl2mat.m`

- follow instructions in script
- for each station range of the same setup check a `.cnv` file and update the reading function in the end of the script for each station range.

##### Sample number logsheets

Fill `.xls` sheet located at `template/logsheets/logsheet.xls`

##### Salinity measurements

*__If not relevant comment out respective part in `template/script/btl2mat.m`__*

Fill `.xls` sheet located at `template/salts/SALTS.xls`. Open `template/salts/salts2mat.m` and adjust `sample_number = [1:24]';` to the represent the number of samples in the sheets. Run the script which will create the file `template/salts/salts2mat.mat` which is loaded in the bottle file processing.

##### Winkler measurements

***If not relevant comment out respective part in `template/script/btl2mat.m`***

Fill `.xlsx` sheet located at `template/winkler/winkler.xlsx`. 

1. fill session
2. get summary from next sheet tab
3. export the summary sheet as `.csv`
4. open `template/winkler/winkler_summary.xlsx`
5. Data > From Text/CSV > import saved `winkler.csv` 
   The reason for step 3-5 is that Matlab can otherwise not read the result as a number but rather reads the equation. 

Finally, run the script `template/winkler/wink2mat.m` which will create the file `template/winkler/wink2mat.mat` which is loaded in the bottle file processing.

### Merge dataset and add results

Using `template/script/combine_mat.m`

- adjust variables in script as needed
  The script does:
- merge the CTD sensor and bottle data into one Matlab `.mat` file 
- include CDOM result
- remove moonpool bad data
- adds further necessary variables for NetCDF conversion

## NetCDF-Creator

Requires the [NetCDF-Creator Software](https://gitlab.com/npolar/netcdf-creator).

Uses the `.json` config file in the `template/netcdf` directory. Use one from a previous year as template and adjust it to the needs.

- load the datafile `template/mat/final.mat`
- save in `template/netcdf/bin`, `template/netcdf/bot` or `template/netcdf/carbon_chemistry` depending on what is converted
