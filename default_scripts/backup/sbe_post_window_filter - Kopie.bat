:: =======================================================================================================
:: This script is called by the station-range_year_call_processing.bat scripts of each year.
:: It provides the processing function specified below to those scripts in order to use sbebatch 
:: to run the following SBE data processing modules:
:: - window filter
:: - average
:
::
:: Variables are utilised as specified in the caller scripts. They don't need to be parsed because
:: when the function is sent back it recognises all the variables.
:: This way, all years use the same processing steps and general changes can only be changed in 
:: one place - the "run_window_filter" function below.
:: The caller batch scripts are calling the "run_window_filter" function by using:
:: path\to\this\file\sbe_post_window_filter.bat run_window_filter
:: ---
:: author: Yannick Kern (yannick.kern@npolar.no)
:: date: 17.02.2022
:: =======================================================================================================
:: using echo OFF will not show every executed line but only the scripted echo feedbacks
@echo off

:: get path of this .bat file when called
set path_bat=%0
:: remove filename and get only path
set path_bat=%path_bat:sbe_post_window_filter.bat=%

:: argument ~1 is what is specified when calling this script which should be "run_window_filter"
:: then this script sends back the "run_window_filter" function which is then used with the 
:: specified variables in the caller batch scripts
call:%~1 %path_bat%

:: end this subscript as soon as function was sent
goto exit


:: FUNCTION DEFINITION
:run_window_filter
	:: --------------------------------------------------------------------
	:: This function gets called by the .bat scripts of each year
	:: It calls sbebatch to run the following SBE data processing modules:
	:: - window filter
	:: - average
	:: The variable names used here are the ones defined in the calling script.
	:: Since the function gets called there all the variables don't have to be parsed.
	:: --------------------------------------------------------------------
	
	:: batch to sbebatch .txt files in current folder of this .bat file
	:: relative path parsed from function call
	set relpath_sbebatch=%~1
	
	
	:: give overview of used settings
	echo --------------------------
	echo Running window filtering
	echo --------------------------

	:: following line enables use of variables in for loops using !! as brackets
	:: this also requires the usage of REM inside loops because :: for comments fails
	SETLOCAL ENABLEDELAYEDEXPANSION


	:: total number of stations
	set /a stn_count=0
	for %%p in (%path_out%*.cnv%) do (
		set do_continue=1
	
		REM extracting filename from path
		set prefix_name=%%~nxp
		
		REM don't continue if "_" in file, only want pure .cnv files
		if "!prefix_name!" neq "!prefix_name:_= !" (
			set do_continue=0
		)
		
		if !do_continue! equ 1 (
			REM extracting station number
			REM syntax:~start_index,length
			REM remove data_suffix ending and then take last 4 digits
			set file_name=!prefix_name:.cnv=!
			set stn_num=!file_name:~-4!
			
			REM echo !file_name!
			
			REM get only number, remove zeros from left side of string
			set stn_int=!stn_num!
			for /f "tokens=* delims=0" %%a in ("!stn_int!") do set stn_int=%%a

			if !stn_int! geq !stn_min! (
				if !stn_int! leq !stn_max! (
					set /a stn_count=!stn_count! + 1
				)
			)
		)
	)	
	
	echo Total number of stations to process: 
	echo ^# !stn_count!
	
	pause

	:: PROCESSING
	:: ----------
	echo -------- Processing --------
	set /a stn_index=0
	for %%p in (%path_out%*.cnv) do (
		
		REM bool variable to continue processing below or not
		set do_continue=1
		
		REM extracting filename from path
		set prefix_name=%%~nxp
	
		set do_this_file=1
		REM don't continue if "_" in file, only want pure .cnv files
		if "!prefix_name!" neq "!prefix_name:_= !" (
			set do_this_file=0
		)
		
		if !do_this_file! equ 1 (
			
			REM extracting station number
			REM syntax:~start_index,length
			REM remove data_suffix ending and then take last 4 digits
			set file_name=!prefix_name:.cnv=!
			set stn_num=!file_name:~-4!
			REM remove "Sta" and take 4 digits afterwards
			REM approch above is more bulletproof
			REM set stn_num=!prefix_name:~3,4!
			
			REM get only number, remove zeros from left side of string
			set stn_int=!stn_num!
			for /f "tokens=* delims=0" %%a in ("!stn_int!") do set stn_int=%%a
			REM if all zeros got removed and string empty it was station name 0
			REM then set stn_int to 0 again
			if [!stn_int!] equ [] (set stn_int=0)
			

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
				

				REM get .cnv filename
				for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_out%*!stn_num!".cnv"`) do (
					set cnv_file=%%F
				)
				
				
				REM window filter (short)
				echo  - window filter ^(short^)...
				sbebatch %relpath_sbebatch%sbebatch_window_filter_short.txt %path_psa% %path_out%!cnv_file! %path_out% !file_name!
				REM in this step the filename got appended by _wf to not overwrite the original .cnv file
				REM this way this complete filter routine can be run separately and again with different filter settings
				REM and the .cnv file doesn't need to be made from scratch each time
				
				REM get _wf.cnv filename
				for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_out%*!stn_num!"_wf.cnv"`) do (
					set cnv_wf_file=%%F
				)
				
				REM average
				REM averaging over _wf.cnv file
				echo  - averaging...
				sbebatch %relpath_sbebatch%sbebatch_average.txt %path_psa% %path_out%!cnv_wf_file! %path_out% !file_name!
				
				
				REM delete _wf.cnv file again because we are now working on the _bin file
				del %path_out%!cnv_wf_file!
				
				REM window filter (long)
				REM get _bin.cnv filename
				for /F "tokens=* USEBACKQ" %%F in (`dir /b %path_out%*!stn_num!"_bin.cnv"`) do (
					set cnv_bin_file=%%F
				)
				echo  - window filter ^(long^)...
				sbebatch %relpath_sbebatch%sbebatch_window_filter_long.txt %path_psa% %path_out%!cnv_bin_file! %path_out% !file_name!
				
				echo  - window filter ^(smoothening^)...
				sbebatch %relpath_sbebatch%sbebatch_window_filter_final.txt %path_psa% %path_out%!cnv_bin_file! %path_out% !file_name!
				
				
			)
		)
	)
	echo DONE
	pause
goto:eof


:exit
exit /b