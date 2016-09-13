% init
clear; 
close all; 

% setup_nctoolbox

% stageFolder = '/mnt/drive1/jj/nexrad/data/stage4/2011/';
% timeStepList = [8,9,10,11,12,13];
% timeStepList = 1:7;
% timeStepList = 13:24;
% timeStepList = 1:23; 
timeStepList = 1:24; 

% selectDate = [2015,06,08]; 
% selectRange = [33,41,-89,-79]; 

selectDate = [2015,08,11]; 
selectRange = [36,46,-77,-64]; 

% selectDate = [2015,09,19]; 
% selectRange = [39,44,-90,-83]; 

% selectDate = [2015,09,30]; 
% selectRange = [35,49,-81,-60]; 

% selectDate = [2015,10,28]; 
% selectRange = [35,43,-88,-80]; 

% selectDate = [2015,11,18]; 
% selectRange = [32,41,-88,-83]; 

for timeStep = timeStepList

  % stageFile = fullfile(stageFolder,sprintf('ST4.20110425%02d.01h',timeStep)); 
    try
      gpmData = readgpm(selectDate(1),selectDate(2),selectDate(3),timeStep,'NS'); 
    catch
      disp(sprintf('Cannot find file for timestep %02d',timeStep)); 
      continue; 
    end

    % radar = ncgeodataset(stageFile); 
    % rain = radar.geovariable(radar.variables(3)); 
    % grid = rain.grid_interop(1,:,:); 
    % lat(:,:) = grid.lat; 
    % lon(:,:) = grid.lon; 
    % raindata(:,:) = double(rain.data(1,:,:)); 

    % lonMin = -87; lonMax = -64; 
    % latMin = 27;  latMax = 45; 

    latMin = selectRange(1); 
    latMax = selectRange(2); 
    lonMin = selectRange(3); 
    lonMax = selectRange(4); 

    latRange = latMax - latMin; 
    lonRange = lonMax - lonMin; 
    [latGrid, lonGrid] = meshgrid(latMin:latMax,lonMin:lonMax); 

    axisRange = [lonMin latMin lonRange latRange]; 

    lat = gpmData.lat; 
    lon = gpmData.lon; 
    precipRate = gpmData.precipRate; 
    precipType = gpmData.precipType; 

    ind = find(lat > latMin & lat < latMax & lon > lonMin & lon < lonMax); 
    
    if (~isempty(ind))
      disp(sprintf('Found match for %d',timeStep)); 
      % continue; 
    end

    
    m_proj('miller');
    m_pcolor(lon,lat,precipRate); shading flat; colorbar; 
    hold on; 
    m_hatch(lonGrid,latGrid,'cross','color','r'); 
    rectangle('position',axisRange, 'facecolor','none')
    m_coast('color','k'); 
    m_grid('linestyle','none','fancy','tickdir','out'); 
    caxis([0 5]);
    title(sprintf('GPM Precip Rate (%02d H)',timeStep));
    print('-dpng','-r500',sprintf('./images/test/img_%4d%02d%02d_%02d.png',selectDate(1),selectDate(2),selectDate(3),timeStep)); 
    close all; 

    disp(timeStep); 

end


