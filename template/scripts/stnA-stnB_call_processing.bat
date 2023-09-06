:: =======================================================================================================
:: This script will automatically process the files specified in the directories in the VARIABLES section.
:: It uses sbebatch to run the following SBE data processing modules:
:: - datacnv
:: - filter
:: - cell thermal mass
:: - loop edit
:: - derive
:: - average
:: - bottle summary
:: - window filter
:: See VARIABLES section for customising. There you can also choose whether to match config files to
:: each respective station or take a general config file for a specific range of stations.
:: ---
:: author: Yannick Kern (yannick.kern@npolar.no)
:: date        : 03.11.2021
:: last edited : 17.02.2022
:: =======================================================================================================
:: using echo OFF will not show every executed line but only the scripted echo feedbacks
echo OFF


:: ----------------
:: GLOBAL VARIABLES
:: ----------------

:: DIRECTORIES
:: -----------
:: NOTE: all path variables have to end with a \
set path_data=..\raw\
:: suffix of raw data file (hex|dat)
set data_suffix=hex
set path_out=..\proc\
set path_psa=..\setup\psa_test\
:: path to respective con/xmlcon files of each instrument
set path_con=..\raw\

:: XML FILES
:: ---------
:: use matching config files or not
:: if 1 : uses matching con file of each station
:: if 0 : uses main con file as specified below
set do_match_con_to_station=0

:: location of single xmlcon/con file to be used (only relevant if do_match_con_to_station=0)
:: specify main_con_filename including suffix .con or .xmlcon
:: if using multiple con files for specific station ranges it is best to copy this script
:: and specify the file and station range below for each script
set main_con_filename=Sta0001.XMLCON
set path_main_con=..\setup\


:: STATION RANGE
:: -------------
:: station numbers for this con file (only relevant if do_match_con_to_station=0)
set stn_min=0
set stn_max=999999


:: MODULES
:: Select wich modules to run
:: if 1 : run that processing module
:: if 0 : don't run that processing module
:: General processing (data conversion, filter, cell thermal mass, loop edit, derive, average, bottle summary)
set do_run_sbe_processing=1

:: Window filtering (CDOM)
:: needs General processing to be ran at least once before
:: replaces _bin.cnv files with window filtered version
set do_run_window_filtering=1

:: ---------------------
:: END  GLOBAL VARIABLES
:: Don't change! anything below this
:: ---------------------



:: PROCESSING
:: Calling "run_sbebatch" function from "sbe_process.bat" using variables specified above
if %do_run_sbe_processing% equ 1 (
	call ..\..\default_scripts\sbe_process.bat run_sbebatch
)

:: Calling "run_window_filter" function from "sbe_post_window_filter.bat" using variables specified above
if %do_run_window_filtering% equ 1 (
	call ..\..\default_scripts\sbe_post_window_filter.bat run_window_filter
)

