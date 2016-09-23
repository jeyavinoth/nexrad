% init
clear; 
close all; 

setup_nctoolbox
make_16_gray

stageFolder = '/mnt/drive4/stage4/2015/';

xtickarray = [];  

% selectDate = [2015,06,08]; 
% cdtRange = [33, 41, -89, -78]; 
% timeStepList = [8,17]; 

% selectDate = [2015,08,11]; 
% cdtRange = [36,46,-77,-64]; 
% timeStepList = [13,21]; 


selectDate = [2015,09,19]; 
cdtRange = [39,44,-93,-83]; 
timeStepList = [03]; 
xtickarray = [-92, -88, -84]; 

% selectDate = [2015,09,30]; 
% cdtRange = [35,49,-81,60]; 
% timeStepList = [07,22,23]; 

% selectDate = [2015,10,28]; 
% cdtRange = [35,43,-88,-80]; 
% timeStepList = [15,16,23]; 

% selectDate = [2015,11,18]; 
% cdtRange = [32,41,-88,-83]; 
% timeStepList = [17,18]; 

dateString = sprintf('%04d%02d%02d',selectDate(1),selectDate(2),selectDate(3)); 

for timeStep = timeStepList

    stageFile = fullfile(stageFolder,sprintf('ST4.%s%02d.01h',dateString,timeStep)); 
    gpmData = readgpm(selectDate(1),selectDate(2),selectDate(3),timeStep,'NS'); 

    radar = ncgeodataset(stageFile); 
    rain = radar.geovariable(radar.variables(3)); 
    grid = rain.grid_interop(1,:,:); 
    lat(:,:) = grid.lat; 
    lon(:,:) = grid.lon; 
    raindata(:,:) = double(rain.data(1,:,:)); 

    gpmLat = gpmData.lat; 
    gpmLon = gpmData.lon; 
    precipRate = gpmData.precipRate; 
    precipType = gpmData.precipType; % 1- startiform, 2 -convective, 3 - other
    precipType = floor(precipType); 

    % getting rid of other precipitations except startiform n convective
    precipType (precipType ~= 1 & precipType ~= 2) = NaN; 
    


  folder = sprintf('/mnt/drive1/jj/nexrad/src/py/outData/%s/',dateString);

  file = fullfile(folder,sprintf('nex_%s_%d.mat',dateString,timeStep)); 
  data = load(file); 

  [lonGrid, latGrid] = meshgrid(data.lon,data.lat); 

  latMin = min(data.lat); latMax = max(data.lat); 
  lonMin = min(data.lon); lonMax = max(data.lon); 

  % latMin = 36; latMax = 40; 
  % lonMin = -85; lonMax = -81; 
  
  latMin = cdtRange(1); latMax = cdtRange(2); 
  lonMin = cdtRange(3); lonMax = cdtRange(4); 

  % manual setup lon/lat range
  % lonMax = -88; 

  % testing cleaning out the data
  % raindata(raindata == 0) = NaN; 
  data.ref(data.ref == -9999) = NaN; 

  ref_surf = squeeze(data.allRef(1,:,:)); 
  ref_surf(ref_surf == -9999) = NaN;  


  % data.cores(data.cores == 0) = NaN; 
  data.cores_40 = double(data.cores_40); 
  % data.cores_40(data.cores_40 == 0) = NaN; 
  % data.cores_bg(data.cores_bg == 0) = NaN; 

  % find cores using Johnny's method of finding convection over 6km 
  temp = data.allRef(12:end,:,:); 
  temp40 = double(temp >= 20); 
  temp40 = squeeze(nansum(temp40,1)); 
  testCore = double(temp40 > 1); 

  ax1 = subplot(2,3,1);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(lonGrid,latGrid,ref_surf); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in','xtick',[-104 -96 -88]); 
  % m_grid('box','fancy','tickdir','in','xtick',[-96 -93 -90]); 
  % m_grid('box','fancy','tickdir','in'); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  % axis([lonMin lonMax latMin latMax]); 
  caxis([0 60]); 
  title('Ref @ 0.5km (dBz)'); 
  colormap(ax1,'jet');

  ax2 = subplot(2,3,2);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(gpmLon,gpmLat,precipRate); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in'); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  caxis([0 12]);
  title('GPM Precip Rate [mm/hr]');
  colormap(ax2,map44)

  ax3 = subplot(2,3,3);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(lon,lat,raindata); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in'); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  caxis([0 12])
  title('Stage 4 [mm/hr]');
  colormap(ax3,map44)

  ax4 = subplot(2,3,4);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(gpmLon,gpmLat,precipType); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  caxis([1 2])
  title('Precip Type from GPM');
  colormap(ax4,'cool')

  ax5 = subplot(2,3,5);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(lonGrid,latGrid,testCore); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  % m_grid('box','fancy','tickdir','in'); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  caxis([0 1])
  title('Core using vertical profile');
  colormap(ax5,'cool')

  % ax5 = subplot(2,3,5);
  % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  % m_pcolor(lonGrid,latGrid,double(ref_surf > 40)); shading flat; colorbar; 
  % hold on; 
  % m_coast('color','k');
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  % caxis([0 1])
  % title('Cores (40dBz @ 0.5km)');
  % colormap(ax5,'cool')

  ax6 = subplot(2,3,6);
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(lonGrid,latGrid,data.cores); shading flat; colorbar; 
  hold on; 
  m_coast('color','k');
  % m_grid('box','fancy','tickdir','in','xtick',[-85 -83 -81]); 
  % m_grid('box','fancy','tickdir','in'); 
  m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
  caxis([0 1])
  title('Steiner* core selection');
  colormap(ax6,'cool')

  suptitle(sprintf('%d/%02d/%02d @ %02dH',selectDate(1),selectDate(2),selectDate(3),timeStep)); 

  orient portrait

  if (exist(sprintf('./images/%s',dateString)) == 0)
    mkdir('./images/',dateString); 
  end
  print('-dpng','-r500',sprintf('./images/%s/img_%s_%02d.png',dateString,dateString,timeStep)); 
  
  close all; 
 
end
