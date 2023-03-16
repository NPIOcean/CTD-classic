## Layout
Duplicate the template folder and rename to desired name.
The folder has to be in the same directory as the folder "default_psa" and "default_scripts". This is because batch files will load processing scripts from those folders.

## Setup
### Folder structure
- copy all CTD files besides `.cnv` and `.btl` to the `raw` folder (.bl|.hdr|.hex|.XMLCON)
- copy one `.XMLCON` file per CTD setting to the `setup` folder, meaning that if the setup of the CTD never changed then one `.XMLCON` file (e.g. of the first station) would be enough for the whole cruise
- modify that `.XMLCON` file for CDOM using
  - Dark output=0
  - Scale factor=1

## Processing
### SBE processing (first time)
Manually run SBE processing once in order to update the `.psa` files located in `new_cruise\setup\psa_general\`.

#### 1 Data Conversion
- Program setup file: new_cruise\setup\psa_general\DatCnv.psa
- Instrument setup file (modified version): \new_cruise\setup\STA0120_modified.XMLCON
- Input directory: new_cruise\raw
- Input files (first station is enough): Sta0120.hex
- Output directory: \new_cruise\proc

#### 2 Filter
- Program setup file: new_cruise\setup\psa_general\Filter.psa
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.cnv
- Output directory: \new_cruise\proc

#### 4 Cell Thermal Mass
- Program setup file: new_cruise\setup\psa_general\CellTM.psa
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.cnv
- Output directory: \new_cruise\proc

#### 5 Loop Edit
- Program setup file: new_cruise\setup\psa_general\LoopEdit.psa
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.cnv
- Output directory: \new_cruise\proc

#### 6 Derive
- Program setup file: new_cruise\setup\psa_general\Derive.psa
- Instrument setup file (modified version): \new_cruise\setup\STA0120_modified.XMLCON
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.cnv
- Output directory: \new_cruise\proc

#### 8 Bin Average
- Program setup file: new_cruise\setup\psa_general\BinAvg.psa
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.cnv
- Output directory: \new_cruise\proc
- Name append: _bin

#### 9 Bottle Summary
- Program setup file: new_cruise\setup\psa_general\BottleSum.psa
- Instrument setup file (modified version): \new_cruise\setup\STA0120_modified.XMLCON
- Input directory: new_cruise\proc
- Input files (first station is enough): Sta0120.ros
- Output directory: \new_cruise\proc

#### 13 Window Filter
Run all three filter .psa once with one station to update them.
- new_cruise\setup\psa_general\W_Filter_short.psa (on .cnv file)
- new_cruise\setup\psa_general\W_Filter_long.psa (on _bin.cnv file)
- new_cruise\setup\psa_general\W_Filter_final_smooth.psa (on _bin.cnv file)
This will for now overwrite files but the automatic processing will produce an extra version at this point ending on _bin_cdom.cnv


### SBE processing (automatic)
Referring to `script\stnA-stnB_call_processing.bat`. See description in the file for further information on how to specify.

### Different instrument setups
In case the CTD setup changes multiple times during the cruise - i.e. sensors get swapped, added or removed. Then the whole process above has to be done again for each specific range of same stations (same CTD setup).
- duplicate the psa_general folder and for instance name it after the station range
- get on XMLCON file for that station range and again modify CDOM
- run all the steps one time manually with SBE processing to adjust the psa files in the duplicated folder
- duplicate the .bat file and adjust it to that station range. This will lead to multiple bat files e.g. the first for stations 1-10, second 11-20 and last for 20-99999.

After setting this up once all bat files can be double clicked to run over the specific station ranges again for reprocessing of if data was updated for instance.

### Different CTDs
In case different CTDs are used on one cruise, for instance one 12 and one 24 rosette version.
Make a raw folder each and treat both as separate sensor setups. Follow procedure like above but instead of having one "raw" folder it is now two. Move the raw files into the specific folders and adjust the batch scripts of each setting to refer to the right raw folder.

## Matlab
Last step is to read the cnv files into Matlab and export them as .nat files. 

### CTD data
Using `script\cnv2mat.m`
- follow instructions in script
- for each station range open a cnv file and update the reading function in the end of the script for each station range.

### Bottle data
Using `script\btl2mat.m`
- follow instructions in script
- for each station range open a cnv file and update the reading function in the end of the script for each station range.
