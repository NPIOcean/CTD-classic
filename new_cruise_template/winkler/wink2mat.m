% WINK2MAT.M

% Script to load winkler results into matlab

% Clear
close all
clear all
clc

% Load from summary file
x = xlsread('winkler_summary');

sample_number = x(:,1);
winkler_result = x(:,2);
clear x

save wink2mat.mat sample_number winkler_result
