%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Developed by Débora Rodrigues
%   LAPMAR (UFPA) and MARETEC (IST)
%   Date: 15/02/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc

%%
addpath E:\YOUR\NETCDF\PATH

% visualizing netcdf data
ncdisp('20100101.nc')

%%
% variables chosen inside the netcdf
ncvars = {'time','lat','lon','PRECTOTCORR'}; % follow the file variables order

% nc files directory
projectdir = 'E:\YOUR\NETCDF\PATH';

% load stations file information
load stations_file.txt
name= stations_file (:,1);
lon= stations_file (:,2);
lat= stations_file (:,3);
%%
% file extension
dinfo = dir(fullfile(projectdir, '*.nc') );
num_files = length(dinfo);
filenames = fullfile( projectdir, {dinfo.name} );
precip = cell(num_files,1);
time = cell(num_files,1);
lats = cell(num_files, 1);
lons = cell(num_files, 1);

%% 
% read the data as a grid
for K = 1 : num_files
  this_file = filenames{K};
  time{K} = ncread(this_file, ncvars{1});
  lats{K} = ncread(this_file, ncvars{2});
  lons{K} = ncread(this_file, ncvars{3});
  precip{K} = (ncread(this_file, ncvars{4}));
end
 
%% 
% k = number of stations
% i = number of nc files
for k=1:200
    dp=[];
    for i = 1:4383 
        % find the closest coordinates to your dataset
        a= lon (k,1)
        [c index] = min(abs(a-lons{i}))

        b= lat (k,1)
        [c index2] = min(abs(b-lats{i}))
        
        % index and index 2 represent the location of the coordinates in
        %netcdf grid
        
        p = precip{i}(index, index2 ,:); 
        p=reshape(p,[],1);
        p=sum(p); % we sum because it is precipitation. Use mean for other variables.
        
        dp(end+1)= p;
    end
    % add to a matrix and save
    result= reshape(dp,[4383,1]); %4383 days, 1 year
    n = name (k,1)
    names = num2str(n,'%.f')
    writematrix(result, [names '.txt']);  
    
    % clear these variables to restart for the other station
    clear dp result 
end
