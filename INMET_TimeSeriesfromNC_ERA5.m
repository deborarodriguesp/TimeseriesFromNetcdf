clear all; close all; clc

%%
addpath E:\GetEra5\Script_python_old

%visualizing netcdf data
ncdisp('2010-01-01.nc')

%%
% variables chosen inside the netcdf
ncvars = {'time','latitude','longitude','tp'}; % follow the file variables order

% nc files directory
projectdir = 'E:\GetEra5\Script_python_old';

load Estacoes_INMET.txt
name= Estacoes_INMET (:,1);
lon= Estacoes_INMET(:,2);
lat= Estacoes_INMET(:,3);
%%
dinfo = dir(fullfile(projectdir, '*.nc') );% entensão do aquivo
num_files = length(dinfo);
filenames = fullfile( projectdir, {dinfo.name} );
precip = cell(num_files,1);
time = cell(num_files,1);
lats = cell(num_files, 1);
lons = cell(num_files, 1);

%% dados armazenados em U e V, subpastas de acordo com o nº de arquivos(num_files)
for K = 1 : num_files
  this_file = filenames{K};
  time{K} = ncread(this_file, ncvars{1});
  lats{K} = ncread(this_file, ncvars{2});
  lons{K} = ncread(this_file, ncvars{3});
  precip{K} = (ncread(this_file, ncvars{4}));
end
 
%% ESTAÇÕES

for k=1:35   
    dp=[];
    for i = 1:4383 % arquivos de entrada 
        
        a= lon (k,1);
        [c index] = min(abs(a-lons{i}));

        b= lat (k,1);
        [c index2] = min(abs(b-lats{i}));

        p = precip{i}(index, index2 ,:); 
        p=reshape(p,[],1);
        p=sum(p); %numero de horas em 1 dia
        dp(end+1)= p;
    end
    
    result= reshape(dp,[4383,1]); %12 meses e 39 anos (meu caso, 4383 dias, 1 ano)
    n = name (k,1);
    names = num2str(n,'%.f');
    writematrix(result, [names '.txt']);  
    clear dp result 

end
