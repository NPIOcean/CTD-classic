% CNV2MAT.M
% Script to read *.cnv files
% Paul A. Dodd | 5 Febraury 2019
% Yannick Kern | 24 July 2022
% Updated to automatically create CDOM struct with origin and filterd data


diary('cnv2mat_LOG.txt')
disp(' ')
disp('-------------------------------------------------------------------')
disp(['LOG from ',datestr(now,'dd.mm.yyyy','local'),' ',datestr(now,'hh:MM:ss','local')])

% Clear
close all
clear all
clc


% Yannick Kern | 18 November 2021
% updated with following changes (usually commented by "%<Yannick>"):
% - filesep (Matlab inbuilt function) as system independant path separator
% - readcnv function: instead of hardcoded line use tab delimter, only
%   need to edit order each year in case it changes and NaN variables (see
%   between EDIT START and EDIT END)
%   - changed ouput of function to be a struct instead of variable names
%     and adjusted the code respectively
% - path_out to mat directory instead of current directory
path_out = ['..' filesep 'mat'];
cruise_year = '2000';
cruise_tag = 'test';

% INSTRUCTIONS:
% 1) Do not remove empty variales. Just don't populate them.
% 2) Edit the function at the bottom to read the *.cnv files correctly
% 3) Do not change the blank array size


% -------------------------------------------------------------------------
% Add version
% -------------------------------------------------------------------------

% Version 0
% 24 July 2022
% Version processed on the ship (not by the ship)
% Y. Kern


version = [0, now];



% -------------------------------------------------------------------------
%% CNV files
% Search for .cnv files to load
% -------------------------------------------------------------------------
endings = {'_bin', '_bin_cdom'};
for val = 1:length(endings)

    cnvpath = ['..' filesep 'proc' filesep]; %<Yannick>: system independant
    A = dir([cnvpath,['*',endings{val},'.cnv']]);


    % -------------------------------------------------------------------------
    %% Pre-allocate
    % Define blank variables 
    % -------------------------------------------------------------------------
    blankvector = zeros(1,length(A)) .* NaN;
    blankarray = zeros(5000,length(A)) .* NaN;

    % STATION METADATA
    stn = blankvector;
    lat = blankvector;
    lon = blankvector;
    time = blankvector;
    baro_start = blankvector;
    baro_stop = blankvector;

    % SCANLINE META
    bin_elapsed = blankarray;
    bin_lat = blankarray;
    bin_lon = blankarray;

    % CTD
    bin_press = blankarray;
    bin_temp1 = blankarray;
    bin_temp2 = blankarray;
    bin_cond1 = blankarray;
    bin_cond2 = blankarray;
    bin_sal1 = blankarray;
    bin_sal2 = blankarray;
    bin_no3 = blankarray;
    bin_sndvel = blankarray;

    % SENSORS
    bin_oxy1 = blankarray;
    bin_oxy2 = blankarray;
    bin_cdom = blankarray;
    bin_trans = blankarray;
    bin_chlorophyll = blankarray;

    clear blankvector blankarray


    % -------------------------------------------------------------------------
    %% Read
    % Read CNV files and populate variables with data
    % -------------------------------------------------------------------------

    % Read each file in turn
    for i = 1:length(A)

        % Read data from the current CNV file
        %[stn(1,i) lat(1,i),lon(1,i),time(1,i),data] = readcnv(cnvpath,A(i).name);

        % Read the data
        %<Yannick>: using struct instead of variable names, assignment below
        %adjusted accordingly
        [stn(1,i), lat(1,i), lon(1,i), time(1,i), o, n] = readcnv(cnvpath,A(i).name);   

        % Line up all the data bins on pressure
        p = 0:1:max(o.press);
        g = find(p == min(o.press));

        bin_press(g:g+n-1,i) = o.press;
        bin_temp1(g:g+n-1,i) = o.temp1;
        bin_temp2(g:g+n-1,i) = o.temp2;
        bin_cond1(g:g+n-1,i) = o.cond1;
        bin_cond2(g:g+n-1,i) = o.cond2;
        bin_oxy1(g:g+n-1,i) = o.oxy1;
        bin_oxy2(g:g+n-1,i) = o.oxy2;

        bin_chlorophyll(g:g+n-1,i) = o.chlorophyll; 

        bin_cdom(g:g+n-1,i) = o.cdom;
        bin_trans(g:g+n-1,i) = o.trans;

        bin_elapsed(g:g+n-1,i) = o.elapsed;
        bin_lat(g:g+n-1,i) = o.scanlat;

        bin_no3(g:g+n-1,i) = o.no3;

        bin_lon(g:g+n-1,i) = o.scanlon;

        bin_sal1(g:g+n-1,i) = o.sal1;
        bin_sal2(g:g+n-1,i) = o.sal2;
        bin_sndvel(g:g+n-1,i) = o.sndvel;

        % Lookup times when CTD was definatley profiling.
        [b] = find(o.press > 15);
        if isempty(g)
            warning('Threshold depth never exceeded')
            baro_start(1,i) = NaN;
            baro_stop(1,i) = NaN;
        else
            baro_start(1,i) = time(1,i) + (o.elapsed(min(b)) ./ (60 .* 60 .* 24)); % convert to days
            baro_stop(1,i) = time(1,i) + (o.elapsed(max(b)) ./ (60 .* 60 .* 24)); % convert to days
        end

        clear p g b o n    
    end
    clear cnvpath A i


    % -------------------------------------------------------------------------
    %% Fix data
    % -------------------------------------------------------------------------
    % Fix a bad patch in the primary salinity.
    % this also affects oter parameters. I think some debris was sucked into
    % the duct.

    % 2019
    % bin_sal1(450:750,51) = bin_sal2(450:750,51);
    % bin_oxy1(450:750,51) = bin_oxy2(450:750,51);
    % bin_cond1(450:750,51) = bin_cond2(450:750,51);
    % 
    % 2019
    % % Fix a couple of spikes in the secondary salinity
    % bin_sal2(1723,6) = bin_sal1(1723,6);
    % bin_sal2(2502,6) = bin_sal1(2502,6);



    % -------------------------------------------------------------------------
    %% Calibration
    % Bottle Calibration 2019
    % -------------------------------------------------------------------------
    % Apply an offset to the primary oxygen sesnors (based on winkler samples)
    % bin_oxy1 = bin_oxy1 - 4.164;
    
    
    
    if strcmp(endings{val}, '_bin')
        bin_cdom_raw = bin_cdom;
    else
        bin_cdom_filtered = bin_cdom;
    end

end



% -------------------------------------------------------------------------
%% CDOM unfiltered
% Import unfiltered CDOM data and make bin_cdom a struct instead
% -------------------------------------------------------------------------
% filtered
clear bin_cdom
bin_cdom.filtered = bin_cdom_filtered; 
clear bin_cdom_filtered

% original
bin_cdom.origin = bin_cdom_raw;

clear bin_cdom_raw

% show warning if different amount of cdom cnv files
if length(bin_cdom.origin(1,:)) ~= length(bin_cdom.filtered(1,:))
    disp('WARNING: more stnXXX_bin.cnv files used thatn stnXXX_bin_cdom.cnv.')
    disp('This might be because there was no CDOM sensor on some stations.')
    disp('In this case duplicate such a station and name stnXXX_bin_cdom.cnv.')
    disp('Since there is no CDOM sensor on it is filled with NaN anyway, but the file hast to exist to get the right dimensions.')
end


% -------------------------------------------------------------------------
% Apply CDOM calibration to get Raman units
% -------------------------------------------------------------------------
cdom_cal_file = ['..' filesep '..' filesep 'results_external' filesep 'cdom' filesep 'FS_DOMfluormeterCalibration.xlsx'];
cdom_cal_sheet = ['FS' cruise_year 'Model'];

cdom_cal = readtable(cdom_cal_file,'Sheet',cdom_cal_sheet,'Range','B2:B5');

coeff.intercept = cdom_cal.Var1(1);
coeff.T = cdom_cal.Var1(2);
coeff.D = cdom_cal.Var1(3);
coeff.TD = cdom_cal.Var1(4);

sensor_data.T = bin_temp1;
sensor_data.D = bin_cdom.filtered;

bin_cdom.cal = coeff.T .* sensor_data.T + coeff.D .* sensor_data.D + coeff.TD .* sensor_data.T .* sensor_data.D + coeff.intercept;
[RowNrs,ColNrs] = find(bin_cdom.cal < 0);
for i = 1:length(RowNrs)
    disp(['bin_cdom.cal(' num2str(ColNrs(i)) ',' num2str(RowNrs(i)) ') < 0 => set to NaN'])
end
% set wrong values to NaN
bin_cdom.cal(bin_cdom.cal < 0) = NaN;

bin_cdom.cal_equation = ['(' num2str(coeff.T) ' x T) + (' num2str(coeff.D) ' x DOMFL) + (' num2str(coeff.TD) ' x T x DOMFL) + (' num2str(coeff.intercept) ')'];

clear cdom_cal cdom_cal_file cdom_cal_sheet coeff sensor_data RowNrs ColNrs


% % -------------------------------------------------------------------------
% %% Station fixes
% % Remove entries that are bad
% % -------------------------------------------------------------------------
% % Station 123 was apparently raised too high after soaking
% % removing first entry
% disp('Removing first depth of station 123')
% ind = find(123==stn);
% entries = 1:2;
% bin_press(entries,ind) = NaN;
% bin_temp1(entries,ind) = NaN;
% bin_temp2(entries,ind) = NaN;
% bin_cond1(entries,ind) = NaN;
% bin_cond2(entries,ind) = NaN;
% bin_oxy1(entries,ind) = NaN;
% bin_oxy2(entries,ind) = NaN;
% bin_chlorophyll(entries,ind) = NaN; 
% bin_cdom.filtered(entries,ind) = NaN;
% bin_cdom.origin(entries,ind) = NaN;
% bin_trans(entries,ind) = NaN;
% bin_elapsed(entries,ind) = NaN;
% bin_lat(entries,ind) = NaN;
% bin_no3(entries,ind) = NaN;
% bin_lon(entries,ind) = NaN;
% bin_sal1(entries,ind) = NaN;
% bin_sal2(entries,ind) = NaN;
% bin_sndvel(entries,ind) = NaN;




% -------------------------------------------------------------------------
%% Save
% Save file
% -------------------------------------------------------------------------
filename = [path_out filesep cruise_tag '_' cruise_year '-v' num2str(version(1)) '.mat']; %<Yannick>: system independant
save (filename, ...
    'stn', 'lat', 'lon', 'time', ...
    'bin_elapsed', 'bin_lat', 'bin_lon', 'bin_no3', ...
    'bin_press', 'bin_temp1', 'bin_temp2', 'bin_cond1', 'bin_cond2', ...
    'bin_sal1', 'bin_sal2', 'bin_sndvel', ...
    'bin_oxy1', 'bin_oxy2', 'bin_cdom', 'bin_trans', 'bin_chlorophyll','version');
disp(['Saved ',filename])

% copyfile(filename,'/run/user/1000/gvfs/smb-share:server=nas1-khaakon.hi.no,share=tokt/Arbeidskatalog_tokt/2022710/CTD/matlab/')


diary off

%% FUNCTIONS
% -------------------------------------------------------------------------save
% Profile (*.cnv) file reading function (edit for each cruise)
% -------------------------------------------------------------------------
%<Yannick>: made function to use struct instead of variable names
% processing station specific
function [stn, lat, lon, time, o, n] = readcnv(cnvpath,file)
    % o = struct with variables on (e.g. o.press, o.sal1, etc.)
    
    % Display station being read
    disp(['Reading ',cnvpath,file])

    % Open file
    fid=fopen([cnvpath,file]);
    clear data

    % Look for binned profile file
    if length(file) == 15 || (length(file) == 20 && strcmp(file(end-8:end),'_cdom.cnv'))
        stn = str2num(file(5:7));    
    % Look for time-binnned LADCP file    
    else
        error('File name format issue')
    end
    
    % EDIT START
    % Only need to order variables here according to column occurance. If a
    % column shall not be used just use a dummy fieldname like 'skip' e.g. 
    % col_order = {'skip';'press';'skip';'temp1';'temp2'; etc}
    % In this case the first column is not used and one between press and 
    % temp1. Because there is a tab before each row the first skip always
    % has to be used because the first column with values (usually press)
    % starts after that tab (column 2 so to speak).
    % Variables that shall be NaN are specified in nan_vars, eg.
    % nan_vars = {'var1';'var2'; etc}
    if ismember(stn,[1])
        col_order = {'skip';'press';'temp1';'temp2';'cond1';'cond2';...
                        'oxy1';'oxy2';'cdom';'chlorophyll';'trans';'elapsed';...
                        'scanlat';'scanlon';'sal1';'sal2'};
        nan_vars = {'sndvel';'no3'}; 
    elseif ismember(stn,2)
        col_order = {'skip';'press';'temp1';'temp2';'cond1';'cond2';...
                        'elapsed';...
                        'scanlat';'scanlon';'sal1';'sal2'};
        nan_vars = {'oxy1';'oxy2';'cdom';'chlorophyll';'trans';'sndvel';'no3'}; 
    elseif ismember(stn,[3:4])
        col_order = {'skip';'press';'temp1';'temp2';'cond1';'cond2';...
                        'cdom';'chlorophyll';'elapsed';...
                        'scanlat';'scanlon';'sal1';'sal2'};
        nan_vars = {'oxy1';'oxy2';'trans';'sndvel';'no3'};  
    end 
    % EDIT END

    % Setup
    body = 0; % To begin with we are not in the body    
    n = 0; % Initilise row counter

    % Read data from the header
    while 1
        tline = fgetl(fid);
            if ~ischar(tline),   break,   end

            % CASE: NMEA Latitude line encountered
            if length(tline) > 15 & tline(1:15) == '* NMEA Latitude'          
                % Read latitude
                latdeg =  str2num(tline(19:20));
                latmin =  str2num(tline(22:26));
                latsig =  tline(28);                
                lat = latdeg + (latmin ./ 60);                
                % Check hemisphere
                if latsig == 'S'
                    lat = (lat .* -1);
                end                
                clear latdeg latmin latsig
            end

            % CASE: NMEA Longitude line encountered
            if length(tline) > 16 & tline(1:16) == '* NMEA Longitude'
                % Read longitude
                londeg =  str2num(tline(20:22));
                lonmin =  str2num(tline(24:28));
                lonsig =  tline(30);                
                lon = londeg + (lonmin ./ 60);                
                % Check hemisphere
                if lonsig == 'W'
                    lon = (lon .* -1);
                end
                clear londeg lonmin lonsig
            end

            % CASE: NMEA time & date line encountered
            if length(tline) > 17 & tline(1:17) == '* NMEA UTC (Time)'               
                time = datenum(tline(21:40));
            end


            if body == 1
                % Incrment row
                n = n + 1;
                
                % split line by whitespace
                splitted_line = str2double(strsplit(tline));
                
                m = 1;
                % assign columns to variables
                for col = 1:numel(col_order)
                    field = col_order{col};
                    o.(field)(n) = splitted_line(m); 
                    m = m + 1;
                end
            end
            
            
            % CASE: End of header encountered encountered
            if body == 0
                if length(tline) == 5 & tline(1:5) == '*END*'
                    body = 1;
                end
            end
    end
    
    % assign empty variables
    for var_ind = 1:numel(nan_vars)
        field = nan_vars{var_ind};
        o.(field) = NaN(1,n); 
    end   

    % close file
    fclose(fid);

    % tidy up
    clear tline i r fid
end

