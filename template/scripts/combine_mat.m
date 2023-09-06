clear

ctd_filename = 'test_2000-v0.mat';
bot_filename = 'test_2000_bottle-v0.mat';
% cdom_filename = 'test_2000_bottle-v0+CDOM.mat';

   
%% CTD
% merge bottle and ctd file into one

% load ctd data
load(['..' filesep 'mat' filesep ctd_filename])
clear ctd_filename


% load bottle data
load(['..' filesep 'mat' filesep bot_filename])
clear bot_filename

% % load cdom data
% load(['..' filesep 'cdom' filesep cdom_filename], 'bot_cdom')
% clear cdom_filename


% -------------------------------------------------------------------------
%% Remove moonpool
% Remove upper part when moonpool was used
% -------------------------------------------------------------------------
var_names = who;
mp_depth = '10';
where_mp = bot_moonpool == 1;

% iterate variables that start with "bin_" and remove lines 1:mpdepth where moonpool flag==1
for i = 1:length(var_names)
    var_name = var_names{i};
    if length(var_name) >= 4 && strcmp(var_name(1:4),'bin_')
        if length(var_name) >= 8 && strcmp(var_name(1:8), 'bin_cdom')
            % cdom struct
            field_names = eval(['fieldnames(' var_name ')']);
            if any(strcmp(field_names,'cal'))
                eval([var_name '.cal(1:' mp_depth ',where_mp) = NaN;']);
            end
            clear field_names
            eval([var_name '.origin(1:' mp_depth ',where_mp) = NaN;']);
            eval([var_name '.filtered(1:' mp_depth ',where_mp) = NaN;']);
        else
            % otherwise
            eval([var_name '(1:' mp_depth ',where_mp) = NaN;']);
        end
    end
end

clear var_names mp_depth i var_name where_mp


% create niskin and pressure dimension
bot_niskin_dimension = (1:length(bot_nisk(:,1)))';
bin_press_dimension = (0:length(bin_press(:,1))-1)';

% save as merged mat file
save(['..' filesep 'mat' filesep 'final'])
disp('Done')

