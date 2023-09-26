% BTL2MAT.M
% 1) Read *.btl bottle files
% 2) Read sample numbers from the CTD logsheet 
% 3) Read sample measurement results from tidy MatLab files
% Paul A. Dodd | 07 September 2019

diary('btl2mat_LOG.txt')
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
% - readbtl_a function: instead of hardcoded line use tab delimter, only
%   need to edit order each year in case it changes and NaN variables (see
%   between EDIT START and EDIT END)
%   - changed ouput of function to be a struct instead of variable names
%     and adjusted the code respectively
% - path_out to "mat" directory instead of current directory
path_out = ['..' filesep 'mat'];
% - add seawater scripts to path
addpath(['..' filesep '..' filesep 'default_scripts' filesep 'seawater' filesep])
addpath(['..' filesep '..' filesep 'default_scripts' filesep 'nan_handling' filesep])

% name of logsheet at directory ../logsheets
logsheet_name = 'logsheet.xls';


% INSTRUCTIONS:
% 1) Do not remove empty variales. Just don't populate them.
% 2) Edit the function at the bottom to read the *.btl files correctly
% 3) Do not change the blank array size
% 4) In %% Logsheets section: Comment/uncomment the order of parameters according to the excel sheet

% Specify the cruise name
cruise_year = '2000';
cruise_tag = 'test';

% -------------------------------------------------------------------------
% Specify the first and last stations to process
% This is in these stations do not have bottle files
% -------------------------------------------------------------------------
firststn = 1;
laststn  = 1;


% -------------------------------------------------------------------------
% Add version
% -------------------------------------------------------------------------
% Version 0
% 24 July 2022
% Version processed on the ship (not by the ship)
% Y. Kern


version = [0, now];


% -------------------------------------------------------------------------
%% Pre-allocate
% Define blank variables 
% -------------------------------------------------------------------------
blankvector = zeros(1,length(firststn:1:laststn)) .* NaN;
blankarray = zeros(24,length(firststn:1:laststn)) .* NaN;

% STATION METADATA
bot_stn     = firststn:1:laststn;
bot_lat     = blankvector;
bot_lon     = blankvector;
bot_time    = blankvector;
bot_cdepth  = blankvector;
bot_icefrac = blankvector;
bot_moonpool = blankvector;
bot_echo_depth = blankvector;

% CTD BOTTLE DATA
bot_nisk = blankarray;
bot_press = blankarray;
bot_temp1 = blankarray;
bot_temp2 = blankarray;
bot_cond1 = blankarray;
bot_cond2 = blankarray;
bot_ctdsal1 = blankarray;
bot_ctdsal2 = blankarray;
bot_oxy1 = blankarray;
bot_oxy2 = blankarray;
bot_chlorophyll = blankarray;
bot_chla_sample1 = blankarray;
bot_chla_sample2 = blankarray;
bot_chla_sample3 = blankarray;

bot_trans = blankarray;
bot_no3_isus = blankarray;

% LABORATORY SALINITY
bot_labsal_sample = blankarray;
bot_labsal = blankarray;

% LABORATORY OXYGEN
bot_winkler_sample1 = blankarray;
bot_winkler_sample2 = blankarray;
bot_winkler_sample3 = blankarray;
bot_winkler(:,:,1) = blankarray;
bot_winkler(:,:,2) = blankarray;
bot_winkler(:,:,3) = blankarray;
bot_laboxy = blankarray;

% D18O
bot_d18o_sample = blankarray;
bot_d18o = blankarray;

% NUTRIENTS
bot_nut_sample = blankarray;
bot_no2 = blankarray;
bot_no3 = blankarray;
bot_po4 = blankarray;
bot_sio4 = blankarray;

% NITRATE & SILICATE ISOTOPES
bot_dsi_sample = blankarray;
bot_dsi = blankarray;
bot_d15n_sample = blankarray;
bot_d15n = blankarray;

% CDOM (& FDOM)
bot_cdom_sample = blankarray;
bot_cdom.a350 = blankarray;
bot_cdom.ex350em450_lab = blankarray;
bot_cdom.ex370em460_ctd = blankarray;
bot_fdom_sample = blankarray;

% I129
bot_i129_sample = blankarray;
bot_i129 = blankarray;

% AT
bot_at_sample = blankarray;
bot_at = blankarray;

% RADIONUCLEIDES
bot_u236_sample = blankarray;
bot_u236 = blankarray;
bot_u233_sample = blankarray;
bot_u233 = blankarray;
bot_c14_sample = blankarray;
bot_c14 = blankarray;

% eDNA
bot_edna_sample1 = blankarray;
bot_edna_sample2 = blankarray;
bot_edna_sample3 = blankarray;

% ONE-OFF's
bot_lignin_sample = blankarray;
bot_phytobac_sample = blankarray;

bot_phagotrophy_sample1 = blankarray;
bot_phagotrophy_sample2(1:24,:) = blankarray;
bot_phagotrophy_sample3(1:24,:) = blankarray;

bot_particle_sample(1:24,:) = blankarray;
bot_dna_sample(1:24,:) = blankarray;
bot_ratio_sample(1:24,:) = blankarray;

bot_photochem_sample1(1:24,:) = blankarray;
bot_photochem_sample2(1:24,:) = blankarray;

bot_photochem_sample3(1:24,:) = blankarray;
bot_n2_fix_sample(1:24,:) = blankarray;
bot_phytoplankton_sample = blankarray;
bot_flowcytometry_sample1 = blankarray;
bot_flowcytometry_sample2 = blankarray;
bot_flowcytometry_sample3 = blankarray;
bot_pocpon_sample = blankarray;
bot_dom_character_sample = blankarray;
bot_bacteria_sample = blankarray;
bot_microplastic_sample = blankarray;
bot_poc_microplastic_sample = blankarray;



clear blankarray blankvector

% -------------------------------------------------------------------------
%% Read
% Read BTL files and populate variables with data
% -------------------------------------------------------------------------
btlpath = ['..' filesep 'proc' filesep]; %<Yannick>: OS independant path

% For each staton    
for i = 1:length(bot_stn)
    
    filename = ['Sta',num2str(bot_stn(i),'%04.0f'),'.btl']; 
    
    % Read the bottle file for this station if one exists
    if exist([btlpath,filename],'file') == 2        
        % CASE: A bottle file exist for this station
        disp(['Station ',num2str(bot_stn(i),'%4.0f'),' - Reading bottle file'])        
        
        % Read the data  
        %<Yannick>: struct instead of variables names, adjusted variables
        % below accordingly
        [lat, lon, time, o, n] = readbtl_a(btlpath,filename,bot_stn(i)); 

        bot_lat(1,i) = lat;
        bot_lon(1,i) = lon;
        bot_time(1,i) = time;
        
        bot_press(1:n,i) = o.press;        
        bot_nisk(1:n,i) = o.nisk;
        bot_press(1:n,i) = o.press;
        bot_temp1(1:n,i) = o.temp1;
        bot_temp2(1:n,i) = o.temp2;
        bot_cond1(1:n,i) = o.cond1;
        bot_cond2(1:n,i) = o.cond2;
        bot_oxy1(1:n,i) = o.oxy1;
        bot_oxy2(1:n,i) = o.oxy2;
        bot_cdom.ex370em460_ctd(1:n,i) = o.cdom;
        bot_chlorophyll(1:n,i) = o.chlorophyll;
        bot_trans(1:n,i) = o.trans;
        bot_ctdsal1(1:n,i) = o.ctdsal1;
        bot_ctdsal2(1:n,i) = o.ctdsal2;
        
        clear lat lon time o n
        

    else
        % CASE: No bottle file exist for this station        
        disp(['Station ',num2str(bot_stn(i),'%03.0f'),' - No bottle file found'])         
    end

end
clear i filename btlpath firststn laststn


%-------------------------------------------------------------------------
%% Logsheets
%Read sample numbers, echo depth and ice fractions from logsheet
%-------------------------------------------------------------------------
disp('Loading sample numbers from CTD logsheets ...')
logsheet = xlsread(['..' filesep 'logsheets' filesep logsheet_name]); %<Yannick>: OS independant path


logsheet = logsheet(:,1:length(bot_lon)+1); % kill any columns without CNV files yet

s = size(logsheet);
% bot_icefrac = logsheet(3,2:s(2));

bot_cdepth  = logsheet(3,2:s(2)) + logsheet(4,2:s(2));
bot_moonpool = logsheet(6,2:s(2));
bot_echo_depth = logsheet(2,2:s(2));


i_line = 8;
% bot_winkler_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_winkler_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_winkler_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
bot_at_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
bot_nut_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
bot_cdom_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
bot_doc_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;



bot_d18o_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
bot_labsal_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% FCM
% bot_flowcytometry_sample1(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_flowcytometry_sample2(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_flowcytometry_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% bot_phytoplankton_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% chlorophyll
% bot_chla_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_chla_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_chla_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% particle absorption
% bot_particle_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% bot_tsm_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% POC & PON
% bot_pocpon_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% DOM character
% bot_dom_character_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% bot_u236_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% bacteria
% bot_bacteria_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% microplastic
% bot_microplastic_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% bot_photochem_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% eDNA
% bot_edna_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_edna_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_edna_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% POC for microplastic
% bot_poc_microplastic_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

% %bot_d15n_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_d15n_sample1(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_d15n_sample2(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_d15n_sample3(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
bot_i129_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_u236_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% %bot_dsi_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% %bot_fdom_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% %bot_127i_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% % One-off stuff:
% bot_lignin_sample(1:24,:) =  logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_phytobac_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% bot_phagotrophy_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_phagotrophy_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_phagotrophy_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% bot_dna_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_ratio_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 

% bot_photochem_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% 
% bot_photochem_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
% bot_n2_fix_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

%bot_n2o_sample1(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
%bot_n2o_sample2(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
%bot_n2o_sample3(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

%bot_ap_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
%bot_chla_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;
%bot_tsm_sample(1:24,:) = logsheet(i_line:i_line+23,2:s(2)); i_line = i_line + 25;

clear s logsheet i_line


% -------------------------------------------------------------------------
%% Results
% Read laboratory salinity results
% -------------------------------------------------------------------------
load(['..' filesep 'salts' filesep 'salts2mat.mat'], 'sample_number','salinity_result') %<Yannick>: OS independant path
disp('Loading salinity results ...')
for i = 1:length(sample_number)
   [r,c] = find(bot_labsal_sample == sample_number(i));
   
   % CASE: The sample is assigned to exaclty one niskin
   if length(r) == 1;
        bot_labsal(r,c) = salinity_result(i,1);
   end
   
   % CASE: The sample is assigned to multiples niskins
   if length(r) > 1
       disp(['Salinity sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
   end   

end
clear r c i salinity_result sample_number

% Check all samples have results
g = find(isfinite(bot_labsal_sample) & isnan(bot_labsal));
disp([num2str(length(g)),' samples are waiting for salinity results:']);
disp(bot_labsal_sample(g))
clear g
% 
% 
% -------------------------------------------------------------------------
% Read laboratory oxygen (winkler) results
% -------------------------------------------------------------------------
disp('Loading winkler results ...')
load(['..' filesep 'winkler' filesep 'wink2mat.mat'], 'sample_number', 'winkler_result')  %<Yannick>: OS independant path

for i = 1:length(sample_number)
   [r1,c1] = find(bot_winkler_sample1 == sample_number(i));
   [r2,c2] = find(bot_winkler_sample2 == sample_number(i));
   [r3,c3] = find(bot_winkler_sample3 == sample_number(i));
   
   % CASE: The sample is assigned to exaclty one niskin as 1st winkler
   if length(r1) == 1;
        bot_winkler(r1,c1,1) = winkler_result(i,1);
   end
   
   % CASE: The sample is assigned to exaclty one niskin as 2nd winkler
   if length(r2) == 1;
        bot_winkler(r2,c2,2) = winkler_result(i,1);
   end
   
   % CASE: The sample is assigned to exaclty one niskin as 3rd winkler
   if length(r3) == 1;
        bot_winkler(r3,c3,3) = winkler_result(i,1);
   end
   
   % CASE: The sample is assigned to multiples niskins
   if length(r1) > 1 | length(r2) > 1 | length(r3) > 1
       disp(['Winkler sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
   end   

end
clear r c i winkler_result sample_number r1 r2 r3 c1 c2 c3 

% Calculate a mean winkler value
bot_laboxy = squeeze(nanmean(permute(bot_winkler,[3 2 1])))';

% Convert from mll to umolkg
bot_laboxy = (44.660 .* bot_laboxy) ./ 1+ (sw_pden(bot_ctdsal1,bot_temp1,bot_press,0)./1000);

% Check all samples have results
g = find(isfinite(bot_winkler_sample1) & isnan(bot_laboxy));
disp([num2str(length(g)),' samples do not have winkler results']);
%disp(bot_winkler_sample1(g))
clear g




% -------------------------------------------------------------------------
% Read d18o results
% -------------------------------------------------------------------------
% load ..\d18o\results\tidyd18o.mat sample_number result_d18o
% 
% for i = 1:length(sample_number)
%    [r,c] = find(bot_d18o_sample == sample_number(i));
%    
%    % CASE: The sample is assigned to exaclty one niskin
%    if length(r) == 1;
%         bot_d18o(r,c) = result_d18o(i,1);
%    end
%    
%    % CASE: The sample is assigned to multiples niskins
%    if length(r) > 1
%        disp(['d18o sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
%    end   
% 
% end
% clear r c i result_d18o sample_number
% 
% % Check all samples have results
% g = find(isfinite(bot_d18o_sample) & isnan(bot_labsal));
% disp([num2str(length(g)),' samples are waiting for d18o results']);
% clear g

% % -------------------------------------------------------------------------
% % Read nutrient results
% % -------------------------------------------------------------------------
% load(['..' filesep 'nutrients' filesep 'tidynuts.mat'], 'sample_number', ...
%     'result_no2', 'result_no3', 'result_po4', 'result_sio')  %<Yannick>: OS independant path
% 
% disp('Loading nutrient results ...')
% 
% for i = 1:length(sample_number)
%    [r,c] = find(bot_nut_sample == sample_number(i));
%    
%    % CASE: The sample is assigned to exaclty one niskin
%    if length(r) == 1;
%         bot_no2(r,c) = result_no2(i,1);
%         bot_no3(r,c) = result_no3(i,1);
%         bot_po4(r,c) = result_po4(i,1);
%         bot_sio4(r,c) = result_sio(i,1);
%    end
%    
%    % CASE: The sample is assigned to multiples niskins
%    if length(r) > 1
%        disp(['Nutrient sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
%    end   
% 
% end
% clear r c i result_no2 result_no3 result_po4 result_sio sample_number
% 
% % Check all samples have results
% g = find(isfinite(bot_nut_sample) & isnan(bot_no3));
% disp([num2str(length(g)),' samples are waiting for nutrient results']);
% clear g

% -------------------------------------------------------------------------
% Read CDOM results
% -------------------------------------------------------------------------
% load ..\cdom\results\tidycdom.mat sample_number result_a350 result_ex350em450
% 
% for i = 1:length(sample_number)
%    [r,c] = find(bot_cdom_sample == sample_number(i));
%    
%    % CASE: The sample is assigned to exaclty one niskin
%    if length(r) == 1;
%         bot_cdom.a350(r,c) = result_a350(i,1);
%         bot_cdom.ex350em450_lab(r,c) = result_ex350em450(i,1);
%    end
%    
%    % CASE: The sample is assigned to multiples niskins
%    if length(r) > 1
%        disp(['CDOM sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
%    end   
% 
% end
% clear r c i result_a350 result_ex350em450 sample_number
% 
% % Check all samples have results
% g = find(isfinite(bot_cdom_sample) & isnan(bot_cdom.a350));
% disp([num2str(length(g)),' samples are waiting for CDOM results']);
% clear g


% -------------------------------------------------------------------------
% Read I129 results
% -------------------------------------------------------------------------
% load ..\i129\tidyi129.mat sample_number result_i129
% 
% for i = 1:length(sample_number)
%    [r,c] = find(bot_i129_sample == sample_number(i));
%    
%    % CASE: The sample is assigned to exaclty one niskin
%    if length(r) == 1;
%         bot_i129(r,c) = result_i129(i,1);
%    end
%    
%    % CASE: The sample is assigned to multiples niskins
%    if length(r) > 1
%        disp(['I129 sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
%    end   
% 
% end
% clear r c i result_i129 sample_number
% 
% % Check all samples have results
% g = find(isfinite(bot_i129_sample) & isnan(bot_i129));
% disp([num2str(length(g)),' samples are waiting for i129 results']);
% clear g

% -------------------------------------------------------------------------
% Read AT results
% -------------------------------------------------------------------------
% load ..\at\tidyat.mat sample_number result_at
% 
% for i = 1:length(sample_number)
%    [r,c] = find(bot_at_sample == sample_number(i));
%    
%    % CASE: The sample is assigned to exaclty one niskin
%    if length(r) == 1;
%         bot_at(r,c) = result_at(i,1);
%    end
%    
%    % CASE: The sample is assigned to multiples niskins
%    if length(r) > 1
%        disp(['AT sample ',num2str(sample_number(i)),' used for multiple niskins - result not included'])
%    end   
% 
% end
% clear r c i result_at sample_number
% 
% % Check all samples have results
% g = find(isfinite(bot_at_sample) & isnan(bot_at));
% disp([num2str(length(g)),' samples are waiting for AT results']);
% clear g

% -------------------------------------------------------------------------
% Perform some clean-up edits
% -------------------------------------------------------------------------

% CDOM and FDOM have the same sample numbers
%bot_fdom_sample = bot_cdom_sample;


% % -------------------------------------------------------------------------
% % Apply a calibration offsets based on salinity bottle data to the primary
% % and secondary
% % -------------------------------------------------------------------------
% bot_ctdsal1 = bot_ctdsal1 + 0.011;
% bot_ctdsal2 = bot_ctdsal2  + 0.018;
% 
% bot_oxy1 = bot_oxy1 + 0.51;
% bot_oxy2 = bot_oxy2 - 2.61;






% -------------------------------------------------------------------------
%% Save
% Save file
% -------------------------------------------------------------------------



filename = [path_out filesep cruise_tag '_' cruise_year '_bottle-v' num2str(version(1)) '.mat'];

clear logsheet_name path_out
% save (filename, ...
%   'cruise', 'bot_stn', 'bot_time', 'bot_lat', 'bot_lon', ...
%   'bot_nisk', 'bot_press', 'bot_temp1', 'bot_temp2', 'bot_cond1', 'bot_cond2', ...
%   'bot_no3_isus',...
%   'bot_oxy1', 'bot_oxy2', 'bot_laboxy',...
%   'bot_chlorophyll', 'bot_trans', ...
%   'bot_ctdsal1', 'bot_ctdsal2', ...
%   'bot_cdepth', 'bot_icefrac', ...
%   'bot_labsal_sample', 'bot_labsal', ...
%   'bot_d18o_sample', 'bot_d18o', ...
%   'bot_nut_sample', 'bot_no2', 'bot_no3', 'bot_po4', 'bot_sio4', ...
%   'bot_cdom_sample', 'bot_cdom', ...
%   'bot_fdom_sample', ...
%   'bot_i129_sample', 'bot_i129', ...
%   'bot_u236_sample', 'bot_u236', ...
%   'bot_u233_sample', 'bot_u233', ...
%   'bot_c14_sample', 'bot_c14', ...
%   'bot_dsi_sample', 'bot_dsi', ...
%   'bot_d15n_sample', 'bot_d15n', ...
%   'bot_at_sample', 'bot_at')
save(filename)
% copyfile(filename,'/run/user/1000/gvfs/smb-share:server=nas1-khaakon.hi.no,share=tokt/Arbeidskatalog_tokt/2022710/CTD/matlab/')

  
disp(['Saved ',filename])

diary off

%% Functions
% -------------------------------------------------------------------------
% Bottle (*.btl) file reading function (edit for each cruise)
% -------------------------------------------------------------------------

%<Yannick> adjusted readbtl function to work with a struct instead of
%variable names
function [lat, lon, time, o, n] = readbtl_a(btlpath,filename, stn)
    % o = struct with variables on (e.g. o.press, o.sal1, etc.)
    
    % EDIT START
    % Only need to order variables here according to column occurance. If a
    % column shall not be used just use a dummy fieldname like 'skip' e.g. 
    % col_order = {'skip';'press';'skip';'temp1';'temp2'; etc}
    % In this case the first column is not used and one between press and 
    % temp1.
    % Variables that shall be NaN are specified in nan_vars, eg.
    % nan_vars = {'var1';'var2'; etc}
    if ismember(stn,1)
        col_order = {'skip';'nisk';'skip';'skip';'skip';'ctdsal1';'ctdsal2';...
            'press';'temp1';'temp2';'cond1';'cond2';'oxy1';'oxy2';'cdom';...
            'chlorophyll';'trans'};
        nan_vars = {};
    elseif ismember(stn,2)
        col_order = {'skip';'nisk';'skip';'skip';'skip';'ctdsal1';'ctdsal2';...
            'press';'temp1';'temp2';'cond1';'cond2'};
        nan_vars = {'oxy1';'oxy2';'cdom';...
            'chlorophyll';'trans'};
    elseif ismember(stn,[3:4])
        col_order = {'skip';'nisk';'skip';'skip';'skip';'ctdsal1';'ctdsal2';...
            'press';'temp1';'temp2';'cond1';'cond2';'cdom';...
            'chlorophyll'};
        nan_vars = {'oxy1';'oxy2';'trans'};
    end
    % EDIT END

    % Open file
    fid=fopen([btlpath,filename]);
    n = 0; % reset row counter
    
    % Read file line-by-line until the end
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


        % Read values from data lines using the string '(avg)' to identify
        % NB! Set to NaN is the sesonr was not installed / not available
        
        if length(tline) > 4 & ~strcmp(tline(1),'#') & ~strcmp(tline(1),'*') & strcmp(tline(end-4:end),'(avg)')
            
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
    end
    
    % assign empty variables
    for var_ind = 1:numel(nan_vars)
        field = nan_vars{var_ind};
        o.(field) = NaN(1,n); 
    end  

    % close the file
    fclose(fid);  
 
end


