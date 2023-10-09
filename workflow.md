# `CTD-classic` workflow

*Written by Yannick Kern - located at [the CTD-classic git repository](https://github.com/NPIOcean/CTD-classic/blob/main/workflow.md)*

# Workflow


This describes the workflow for applying the `CTD-classic` processing procedure to CTD data. It refers to a GitHub repository which is located here:

-  [github.com/NPIOcean/CTD-classic](https://github.com/NPIOcean/CTD-classic)

There, you will find the files and folder structure decribed below. 

To begin, clone the repository to your computer. You will find the folder `template` in the repository - this is a starting point for going through the steps below.

---


**General processing chain:**

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

Duplicate the template folder `template` and rename to desired `[[cruiseTag]]` name (e.g. `fs_YYYY`). Keep in same directory as `default_psa` and `default_scripts`. This is because batch files will load processing scripts from those folders using relative pathing. If starting in a new work directory make sure to take a copy of those two directories as well.

### B) Init structure

- copy all CTD files besides `.cnv` and `.btl` to the `raw` folder (`.bl`|`.hdr`|`.hex`|`.XMLCON`)
- copy one `.XMLCON` file per CTD setting to the `setup` folder, meaning that if the setup of the CTD never changed then one `.XMLCON` file (e.g. of the first station) would be enough for the whole cruise
- (if relevant) modify that `.XMLCON` file for CDOM using
  - Dark output=0
  - Scale factor=1

### C) Initial setup for SBE batch processing

Manually run SBE processing once in order to update the `.psa` files located in `[cruiseTag]\setup\psa_general\`. For the example files on the repo here a duplicate was used (`[cruiseTag]\setup\psa_test\`) to keep the default `.psa` files untouched.

#### 1 Data Conversion

- Program setup file: `[cruiseTag]\setup\psa_general\DatCnv.psa`
- Instrument setup file: `\[cruiseTag]\setup\Sta0001.XMLCON`
- Input directory: `[cruiseTag]\raw`
- Input files (first station is enough): `Sta0001.hex`
- Output directory: `\[cruiseTag]\proc`

#### 2 Filter

- Program setup file: `[cruiseTag]\setup\psa_general\Filter.psa`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\[cruiseTag]\proc`

#### 4 Cell Thermal Mass

- Program setup file: `[cruiseTag]\setup\psa_general\CellTM.psa`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\[cruiseTag]\proc`

#### 5 Loop Edit

- Program setup file: `[cruiseTag]\setup\psa_general\LoopEdit.psa`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\[cruiseTag]\proc`

#### 6 Derive

- Program setup file: `[cruiseTag]\setup\psa_general\Derive.psa`
- Instrument setup file: `[cruiseTag]\setup\Sta0001.XMLCON`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\[cruiseTag]\proc`

#### 8 Bin Average

- Program setup file: `[cruiseTag]\setup\psa_general\BinAvg.psa`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.cnv`
- Output directory: `\[cruiseTag]\proc`
- Name append: `_bin`

#### 9 Bottle Summary

- Program setup file: `[cruiseTag]\setup\psa_general\BottleSum.psa`
- Instrument setup file (modified version): `[cruiseTag]\setup\Sta0001.XMLCON`
- Input directory: `[cruiseTag]\proc`
- Input files (first station is enough): `Sta0001.ros`
- Output directory: `\[cruiseTag]\proc`

#### 13 Window Filter

Run all three filter `.psa` once with one station to update them.

- `[cruiseTag]\setup\psa_general\W_Filter_short.psa` (on `.cnv` file)
- `[cruiseTag]\setup\psa_general\W_Filter_long.psa` (on `_bin.cnv` file)
- `[cruiseTag]\setup\psa_general\W_Filter_final_smooth.psa` (on `_bin.cnv` file)
  This will for this manual run only overwrite files but the automatic processing later will produce an extra version at this point ending on `_bin_cdom.cnv`

### D) Setup automated SBE batch processing

We have now set up the `.psa` files for your dataset. We can now run the batch processing script which will process *all* the data in the `[cruiseTag]\raw` folder, adding new files to the `[cruiseTag]\proc`.  

The template batch processing file is found here:

-  `[cruiseTag]\script\stnA-stnB_call_processing.bat`. 

Start with renaming the batch script to reflect the stations it will process, e.g.  `[cruiseTag]\script\stn1-stn99_call_processing.bat`. There will need to be one `.bat` file everytime the instrument setup on the CTD has changed (see [Additional steps](#e-additional-steps)).

The file can now be executed from a terminal, or by **double clicking the file** in Windows Explorer.
_____

There are many configuration options in this file. You can toggle these options by editing the `.bat` file itself.

*Examples of options you can edit:*

- *Process only profiles 30 to 35 (not all CTDs)*
- *Don't use window filtering for CDOM*
- *Use a different .XMLCON file*
- *etc..*

_____


When you run the `.bat` file, a terminal window will open up, and you will be prompted to **press a key**.

When you do, you should see some windows popping in and out - this is the SBEDataProcessing software running through the processing steps for all the files you have specified. You can follow along with what is going on in the terminal. When you see `DONE` in the terminal window, the processing is complete, and you can press a key to exit.

*Check the contents of* `[cruiseTag]\proc` *to confirm that the processing did actually produce new files.*

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

Using `[cruiseTag]/script/cnv2mat.m`

- follow instructions in script
- for each stations range of the same setup check a `.cnv` file and update the reading function in the end of the script for each station range.

#### Bottle data

Using `[cruiseTag]/script/btl2mat.m`

- follow instructions in script
- for each station range of the same setup check a `.cnv` file and update the reading function in the end of the script for each station range.

##### Sample number logsheets

Fill `.xls` sheet located at `[cruiseTag]/logsheets/logsheet.xls`

##### Salinity measurements

*__If not relevant comment out respective part in `[cruiseTag]/script/btl2mat.m`__*

Fill `.xls` sheet located at `[cruiseTag]/salts/SALTS.xls`. Open `[cruiseTag]/salts/salts2mat.m` and adjust `sample_number = [1:24]';` to the represent the number of samples in the sheets. Run the script which will create the file `[cruiseTag]/salts/salts2mat.mat` which is loaded in the bottle file processing.

##### Winkler measurements

***If not relevant comment out respective part in `[cruiseTag]/script/btl2mat.m`***

Fill `.xlsx` sheet located at `[cruiseTag]/winkler/winkler.xlsx`. 

1. fill session
2. get summary from next sheet tab
3. export the summary sheet as `.csv`
4. open `[cruiseTag]/winkler/winkler_summary.xlsx`
5. Data > From Text/CSV > import saved `winkler.csv` 
   The reason for step 3-5 is that Matlab can otherwise not read the result as a number but rather reads the equation. 

Finally, run the script `[cruiseTag]/winkler/wink2mat.m` which will create the file `[cruiseTag]/winkler/wink2mat.mat` which is loaded in the bottle file processing.

### Merge dataset and add results

Using `[cruiseTag]/script/combine_mat.m`

- adjust variables in script as needed
  The script does:
- merge the CTD sensor and bottle data into one Matlab `.mat` file 
- include CDOM result
- remove moonpool bad data
- adds further necessary variables for NetCDF conversion

## NetCDF-Creator

Requires the [NetCDF-Creator Software](https://gitlab.com/npolar/netcdf-creator).

Uses the `.json` config file in the `[cruiseTag]/netcdf` directory. Use one from a previous year as [cruiseTag] and adjust it to the needs.

- load the datafile `[cruiseTag]/mat/final.mat`
- save in `[cruiseTag]/netcdf/bin`, `[cruiseTag]/netcdf/bot` or `[cruiseTag]/netcdf/carbon_chemistry` depending on what is converted
