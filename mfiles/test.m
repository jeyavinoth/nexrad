% init
clear
addpath('~/Documents/MATLAB/nctoolbox/'); 
setup_nctoolbox

% reading in data
%{
folder = '/mnt/drive1/jj/nexrad/data/stage4/test/'; 

file = sprintf('%s%s',folder,'ST4.2014010214.01h'); 
radar = ncgeodataset(file); 

rain = radar.geovariable(radar.variables(3)); 
grid = rain.grid_interop(1,:,:); 
lat(:,:) = grid.lat; 
lon(:,:) = grid.lon;

raindata(:,:) = double(rain.data(1,:,:));  

pcolor(lon,lat,raindata); shading flat; 
%}

folder = '/mnt/drive1/jj/nexrad/data/stage4/2011/';
dirList = dir(fullfile(folder,'ST4.20110425*01h'));
fileList = char({dirList.name}); 

% nexFolder = '/mnt/drive1/jj/nexrad/src/py/outData/'; 
% nexDirList = dir(fullfile(nexFolder,'*.mat')); 
% nexFiles = char({nexDirList.name}); 
% nexTime = str2num(nexFiles(:,14:15)) + str2num(nexFiles(:,16:17))./60; 

for fileLoop = 1:size(fileList,1)
  file = fullfile(folder,fileList(fileLoop,:)); 

  filename = fileList(fileLoop,:); 
  yyyy = filename(5:8); 
  mm = filename(9:10); 
  dd = filename(11:12); 
  hh = filename(13:14); 

  titlestr = sprintf('%s-%s-%s (%s h)',yyyy,mm,dd,hh);

  radar = ncgeodataset(file); 
  rain = radar.geovariable(radar.variables(3)); 
  grid = rain.grid_interop(1,:,:); 
  lat(:,:) = grid.lat; 
  lon(:,:) = grid.lon; 
  raindata(:,:) = double(rain.data(1,:,:)); 

  close all;
  pcolor(lon,lat,raindata); shading flat; 
  axis([-99.5 -96.5 35.5 38.0]); 
  caxis([0 20]); colorbar; 
  title(titlestr); 
  
  print('-djpeg99',sprintf('./images/%s.jpg',fileList(fileLoop,:))); 

  disp(file);
end
