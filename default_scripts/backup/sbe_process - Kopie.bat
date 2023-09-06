:: =======================================================================================================
:: This script is called by the station-range_year_call_processing.bat scripts of each year.
:: It provides the processing function specified below to those scripts in order to use sbebatch 
:: to run the following SBE data processing modules:
:: - datacnv
:: - filter
:: - cell thermal mass
:: - loop edit
:: - derive
:: - average
:: - bottle summary
::
:: Variables are utilised as specified in the caller scripts. They don't need to be parsed because
:: when the function is sent back it recognises all the variables.
:: This way, all years use the same processing steps and general changes can only be changed in 
:: one place - the "run_sbebatch" function below.
:: The caller batch scripts are calling the "run_sbebatch" function by using:
:: path\to\this\file\sbe_process.bat run_sbebatch
:: ---
:: author: Yannick Kern (yannick.kern@npolar.no)
:: date: 03.11.2021
:: =======================================================================================================
:: using echo OFF will not show every executed line but only the scripted echo feedbacks
@echo off

:: get path of this .bat file when called
set path_bat=%0
:: remove filename and get only path
set path_bat=%path_bat:sbe_process.bat=%

:: argument ~1 is what is specified when calling this script which should be "run_sbebatch"
:: then this script sends back the "run_sbebatch" function which is then used with the 
:: specified variables in the caller batch scripts
call:%~1 %path_bat%

:: end this subscript as soon as function was sent
goto exit


:: FUNCTION DEFINITION
:run_sbebatch
	:: --------------------------------------------------------------------
	:: This function gets called by the .bat scripts of each year
	:: It calls sbebatch to run the following SBE data processing modules:
	:: - datacnv
	:: - filter
	:: - cell thermal mass
	:: - loop edit
	:: - derive
	:: - average
	:: - bottle summary
	:: The variable names used here are the ones defined in the calling script.
	:: Since the function gets called there all the variables don't have to be parsed.
	:: --------------------------------------------------------------------
	
	:: batch to sbebatch .txt files in current folder of this .bat file
	:: parsed from function call
	set relpath_sbebatch=%~1
	
	
	:: give overview of used settings
	echo -------- Settings --------
	echo data dir     : %path_data%
	echo data suffix  : "%data_suffix%"
	echo psa files    : %path_psa%
	echo output dir   : %path_out%
	if %do_match_con_to_station% equ 0 (
		echo config file  : %path_main_con%%main_con_filename%
	) else (
		echo matching config file per station
		echo  ^> located in: %path_con%
	)
	echo station range: %stn_min% - %stn_max%
	echo --------------------------
	echo Press any key to continue OR close terminal to adjust settings
	pause
	echo --------------------------

	:: following line enables use of variables in for loops using !! as brackets
	:: this also requires the usage of REM inside loops because :: for comments fails
	SETLOCAL ENABLEDELAYEDEXPANSION


	:: CHECK REQUIREMENTS
	:: ------------------
	:: check if folder ends on \ and if it exists
	:: data path
	echo Checking data path existence...
	set is_fine=true
	if %path_data:~-1% neq \ set is_fine=false
	if not exist %path_data% set is_fine=false
	if %is_fine% equ false (echo Data directory "%path_data%" not existing or not ending on \
		pause & exit /b)
	:: output path
	echo Checking output path existence...
	set is_fine=true
	if %path_out:~-1% neq \ set is_fine=false
	if not exist %path_out% set is_fine=false
	if %is_fine% equ false (echo Output directory "%path_out%" not existing or not ending on \
		pause & exit /b)
	:: config path
	echo Checking config file existence...
	set is_fine=true
	if %path_con:~-1% neq \ set is_fine=false
	if not exist %path_con% set is_fine=false
	if %is_fine% equ false (echo Config file directory "%path_con%" not existing or not ending on \
		pause & exit /b)
	:: psa path
	echo Checking psa files existence...
	set is_fine=true
	if %path_psa:~-1% neq \ set is_fine=false
	if not exist %path_psa% set is_fine=false
	if %is_fine% equ false (echo PSU setup file directory "%path_psa%" not existing or not ending on \
		pause & exit /b)
	:: psu files existing
	set is_fine=true
	if not exist %path_psa%BinAvg.psa (echo Can't find %path_psa%BinAvg.psa & set is_fine=false)
	if not exist %path_psa%BottleSum.psa (echo Can't find %path_psa%BottleSum.psa & set is_fine=false)
	if not exist %path_psa%CellTM.psa (echo Can't find %path_psa%BottleSum.psa & set is_fine=false)
	if not exist %path_psa%DatCnv.psa (echo Can't find %path_psa%BottleSum.psa & set is_fine=false)
	if not exist %path_psa%Derive.psa (echo Can't find %path_psa%Derive.psa & set is_fine=false)
	if not exist %path_psa%Filter.psa (echo Can't find %path_psa%Filter.psa & set is_fine=false)
	if not exist %path_psa%LoopEdit.psa (echo Can't find %path_psa%LoopEdit.psa & set is_fine=false)
	if %is_fine% equ false (echo You might want to change the "path_psa" variable & pause & exit /b)

	echo Requirement check complete^!
	echo --------------------------

	:: total number of stations
	set /a stn_count=0
	for %%p in (%path_data%*.%data_suffix%) do (
		REM extracting filename from path
		set xml_name=%%~nxp
		
		REM extracting station number
		REM syntax:~start_index,length
		REM remove data_suffix ending and then take last 4 digits
		set file_name=!xml_name:.%data_suffix%=!
		set stn_num=!file_name:~-4!
		
		REM get only number, remove zeros from left side of string
		set stn_int=!stn_num!
		for /f "tokens=* delims=0" %%a in ("!stn_int!") do set stn_int=%%a

		if !stn_int! geq !stn_min! (
			if !stn_int! leq !stn_max! (
				set /a stn_count=!stn_count! + 1
			)
		)
	)	
	
	echo Total number of stations to process: 
	echo ^# !stn_count!

	:: PROCESSING
	:: ----------
	echo -------- Processing --------
	set /a stn_index=0
	for %%p in (%path_data%*.%data_suffix%) do (
		REM bool variable to continue processing below or not
		set do_continue=1
		
		REM extracting filename from path
		set xml_name=%%~nxp
		
		REM extracting station number
		REM syntax:~start_index,length
		REM remove data_suffix ending and then take last 4 digits
		set file_name=!xml_name:.%data_suffix%=!
		set stn_num=!file_name:~-4!
		REM remove "Sta" and take 4 digits afterwards
		REM approch above is more bulletproof
		REM set stn_num=!xml_name:~3,4!
		
		REM get only number, remove zeros from left side of string
		set stn_int=!stn_num!
		for /f "tokens=* delims=0" %%a in ("!stn_int!") do set stn_int=%%a
		REM if all zeros got removed and string empty it was station name 0
		REM then set stn_int to 0 again
		if [!stn_int!] equ [] (set stn_int=0)
		
		
		REM get name of *.con or *.xmlcon file if no main_con_filename is specified
		if %do_match_con_to_station% equ 1 (
			for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_data%*!stn_num!*"con"`) do (
				set con_file=%path_con%%%F
			)
		) else (
			REM otherwise use main_con_filename as con_file
			set con_file=%path_main_con%%main_con_filename%
		)
		
		REM check if within station number bounds if specified
		REM end processing if above max
		if !stn_int! GTR !stn_max! (
			echo Stopped after last station in range: ^# %stn_max%
			pause
			exit /B
		)
		REM skip stations below min
		if !stn_int! LSS !stn_min! (
			set do_continue=0
		)
		
		REM only continue if do_continue=1
		if !do_continue! equ 1 (
			REM get name of data file of this station number
			for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_data%*!stn_num!".%data_suffix%"`) do (
				set data_file=%%F
			)
			set stn_name=!stn_num!
			REM check if con file exists
			if not exist !con_file! (
				echo Config file "!con_file!" not found. 
				echo Check the beginning of this script that you specified it correctly!
				echo Exit
				pause
				exit /b
			)
			REM incerase station index each round
			set /a stn_index=!stn_index! + 1
			set /a stn_mult=!stn_index! * 100
			set /a percent=!stn_mult! / !stn_count!
			
			echo !percent!%% ^(!stn_index! of !stn_count!^): ^"!file_name!^" 
			REM call sbebatch script
			REM /p: path to program setup files (psu|psa)
			REM /c: configuration file (xmlcon|con)
			REM /i: input file name
			REM /o: output folder
			echo  - converting to cnv...
			sbebatch %relpath_sbebatch%sbebatch_datcnv.txt %path_psa% !con_file! %path_data%!data_file! %path_out% !file_name!

			REM get .cnv filename
			for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_out%*!stn_num!".cnv"`) do (
				set cnv_file=%%F
			)
			
			echo  - filter, cell thermal mass, loop edit...
			REM echo sbebatch sbebatch_filter.txt %path_psa% %path_out%!cnv_file! %path_out%
			sbebatch %relpath_sbebatch%sbebatch_process.txt %path_psa% %path_out%!cnv_file! %path_out%  !file_name!
			
			REM derive
			echo  - deriving...
			sbebatch %relpath_sbebatch%sbebatch_derive.txt %path_psa% !con_file! %path_out%!cnv_file! %path_out% !file_name!
			
			REM average
			echo  - averaging...
			sbebatch %relpath_sbebatch%sbebatch_average.txt %path_psa% %path_out%!cnv_file! %path_out% !file_name!
			
			REM bottle summary
			REM get .ros filename
			REM check if ros file exists or maybe no bottle was fired
			set ros_check=0
			for  /f "tokens=*" %%x in ('dir /b %path_out%*!stn_num!".ros" 2^>nul') do set ros_check=1
			if !ros_check! equ 1 (
				for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_out%*!stn_num!".ros"`) do (
					set ros_file=%%F
				)
				echo  - bottle summary...
				sbebatch %relpath_sbebatch%sbebatch_bottlesum.txt %path_psa% !con_file! %path_out%!ros_file! %path_out% !file_name!
			) else (
				echo  - skip bottle summary: no bottle fired ^(no %path_out%^*!stn_num!.ros file^)
			)
		)
	)
	echo DONE
	pause
goto:eof


:exit
exit /b