% init
clear; 
close all; 

% setup_nctoolbox

% stageFolder = '/mnt/drive1/jj/nexrad/data/stage4/2011/';
% timeStepList = [8,9,10,11,12,13];
% timeStepList = 1:7;
% timeStepList = 13:24;
% timeStepList = 1:23; 
timeStepList = 2:24; 
timeStepList = 3:4

for timeStep = timeStepList

  % stageFile = fullfile(stageFolder,sprintf('ST4.20110425%02d.01h',timeStep)); 
    gpmData = readgpm(2015,06,08,timeStep,'NS'); 

    % radar = ncgeodataset(stageFile); 
    % rain = radar.geovariable(radar.variables(3)); 
    % grid = rain.grid_interop(1,:,:); 
    % lat(:,:) = grid.lat; 
    % lon(:,:) = grid.lon; 
    % raindata(:,:) = double(rain.data(1,:,:)); 

    lonMin = -87; lonMax = -64; 
    latMin = 27;  latMax = 45; 
    latRange = latMax - latMin; 
    lonRange = lonMax - lonMin; 
    [latGrid, lonGrid] = meshgrid(latMin:latMax,lonMin:lonMax); 

    axisRange = [lonMin latMin lonRange latRange]; 

    lat = gpmData.lat; 
    lon = gpmData.lon; 
    precipRate = gpmData.precipRate; 
    precipType = gpmData.precipType; 
    
  m_proj('miller');
  m_pcolor(lon,lat,precipRate); shading flat; colorbar; 
  hold on; 
  m_hatch(lonGrid,latGrid,'cross','color','r'); 
  rectangle('position',axisRange, 'facecolor','none')
  m_coast('color','k'); 
  m_grid('linestyle','none','fancy','tickdir','out'); 
  caxis([0 5]);
  
  title(sprintf('GPM Precip Rate (%02d H)',timeStep));

  print('-dpng','-r500',sprintf('./images/test/img_20150608_%02d.png',timeStep)); 
  close all; 

  disp(timeStep); 

end


