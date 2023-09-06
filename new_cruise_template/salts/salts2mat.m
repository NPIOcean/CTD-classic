% SALTS2MAT.M

% Script to read in results from the salinometer log sheets stored in
% salts_post.xls. This script deals with conductivity ratios where the
% salinity was too low for the salinometer to calculate the salinity

% Clear
close all
clear all
clc

% -------------------------------------------------------------------------
% Read in sample numbers and salinity / conductivity ratio result from the
% excel file
% -------------------------------------------------------------------------

% Load the excel file and extract useful information
data = xlsread('SALTS.xls');
% sample_number = data(:,1);
sample_number = [1:24]';
bath_temperature = data(:,15);
result = data(:,12);
clear data

% Predefine salinity variables
salinity_result = zeros(length(sample_number),1) .* NaN;

% -------------------------------------------------------------------------
% Results for samples with a salinity of less than 2 are reported as
% conductivity ratio and not salinity, because pss-78 is technically only
% valid at salinities bewtween 2 to 42. 
%
% Here we go though each result. If the result is greater than 2 we use the
% salinity. If the result is less than 2 it is reported as conditity ratio
% and we will use this together with the bath temperature to calculate a
% salinity using the internatinal equation of state for sewater - even
% though we push it beyond the defined range.
% -------------------------------------------------------------------------

for i = 1:length(sample_number)    
    % CASE: salinity measurement
    if result(i) > 2    
        % Include in list of salinity measurements
        salinity_result(i,1) = result(i,1);        
    % CASE: conductivity ratio    
    else
        % Calculate salinity, then include in list of salinity measurements
        salinity_result(i,1) = sw_salt(result(i,1),bath_temperature(i,1),0);     
    end    
end
clear i result bath_temperature

% -------------------------------------------------------------------------
% Save
% -------------------------------------------------------------------------
save salts2mat.mat sample_number salinity_result