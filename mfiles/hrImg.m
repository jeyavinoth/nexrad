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

nexFolder = '/mnt/drive1/jj/nexrad/src/py/outData/'; 
nexDirList = dir(fullfile(nexFolder,'*.mat')); 
nexFiles = char({nexDirList.name}); 
nexTime = str2num(nexFiles(:,14:15)) + str2num(nexFiles(:,16:17))./60; 

for fileLoop = 1:size(fileList,1)
  file = fullfile(folder,fileList(fileLoop,:)); 

  filename = fileList(fileLoop,:); 
  yyyy = filename(5:8); 
  mm = filename(9:10); 
  dd = filename(11:12); 
  hh = filename(13:14); 

  titlestr = sprintf('%s-%s-%s (%s h)',yyyy,mm,dd,hh);

  stageTime = str2num(hh); 
  timeInd = dsearchn(nexTime,stageTime); 

  if (length(timeInd) ~= 1)
    disp(sprintf('%6.2f :: Length of found index more than 1 (length = %d)',stageTime,length(timeInd))); 
    continue; 
  elseif (abs(nexTime(timeInd) - stageTime) > 1) 
    disp(sprintf('%6.2f :: Found file is more than 1 hr time difference',stageTime)); 
    continue; 
  end

  nexData = load(fullfile(nexFolder,nexFiles(timeInd,:))); 

  radar = ncgeodataset(file); 
  rain = radar.geovariable(radar.variables(3)); 
  grid = rain.grid_interop(1,:,:); 
  lat(:,:) = grid.lat; 
  lon(:,:) = grid.lon; 
  raindata(:,:) = double(rain.data(1,:,:)); 

  close all;

  subplot(2,2,1); 
  pcolor(nexData.lon,nexData.lat,nexData.ref); shading flat;
  caxis([0 64]); colorbar; 
  axis([-99.5 -96.5 35.5 38.0]); 
  title(sprintf('NexRAD Reflectivity (dBz %4.2f hrs)',nexTime(timeInd)),'FontSize',10);

  subplot(2,2,2); 
  pcolor(lon,lat,raindata); shading flat; 
  axis([-99.5 -96.5 35.5 38.0]); 
  caxis([0 20]); colorbar; 
  title('Stage 4 data','FontSize',10);
  
  subplot(2,2,3); 
  pcolor(nexData.lon,nexData.lat,double(nexData.cores_40)); shading flat;
  caxis([0 1]); colorbar; 
  axis([-99.5 -96.5 35.5 38.0]); 
  title(sprintf('Reflectivity > 40 dBz'),'FontSize',10);

  subplot(2,2,4); 
  pcolor(nexData.lon,nexData.lat,nexData.cores); shading flat;
  caxis([0 1]); colorbar; 
  axis([-99.5 -96.5 35.5 38.0]); 
  title(sprintf('Selected Cores (Steiner Method)'),'FontSize',10);

  suptitle(titlestr); 
  
  print('-djpeg99',sprintf('./hrImages/%s.jpg',fileList(fileLoop,:))); 

  disp(file);
end
