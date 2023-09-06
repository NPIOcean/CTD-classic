::=====================================================================================================
:: This script will automatically process the files specified in the directories given in the VARIABLES section.
:: It uses sbebatch to run the following SBE data processing modules:
:: - datacnv
:: - filter
:: - cell thermal mass
:: - loop edit
:: - derive
:: - average
:: - bottle summary
:: See VARIABLES section for customising. There you can also choose whether to match config files to
:: each respective station or take a general config file for a specific range of stations.
::
:: The script calls the "sbe_process" function from the folder ..
:: ---
:: author: Yannick Kern (yannick.kern@npolar.no)
:: date: 03.11.2021
:: ====================================================================================================
:: using echo OFF will not show every executed line but only the scripted echo feedbacks
echo OFF


:: ---------
:: VARIABLES
:: ---------
:: path locations relative to the location of this .bat script

:: NOTE: all path variables have to end with a \
set path_data=..\raw\
:: suffix of raw data file (hex|dat)
set data_suffix=hex
set path_out=..\proc\
set path_psa=..\setup\
:: path to respective con/xmlcon files of each instrument
set path_con=..\raw\

:: use matching config files or not
:: if 1 : uses matching con file of each station
:: if 0 : uses main con file as specified below
set do_match_con_to_station=0

:: location of single xmlcon/con file to be used (only relevant if do_match_con_to_station=0)
:: specify main_con_filename including suffix .con or .xmlcon
:: if using multiple con files for specific station ranges it is best to copy this script
:: and specify the file and station range below for each script
set main_con_filename=FILENAME.XMLCON
set path_main_con=..\setup\
:: station numbers for this con file (only relevant if do_match_con_to_station=0)
set stn_min=0
set stn_max=9999

:: ---------
:: ---------



:: PROCESSING
:: Don't change!
:: Calling "run_sbebatch" function from "sbe_process.bat" using variables specified above
call ..\..\default_scripts\sbe_process.bat run_sbebatch
