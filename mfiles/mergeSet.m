% init
clear; 
close all; 

setup_nctoolbox

stageFolder = '/mnt/drive1/jj/nexrad/data/stage4/2011/';
stageFile = fullfile(stageFolder,'ST4.2011042509.01h'); 

  radar = ncgeodataset(stageFile); 
  rain = radar.geovariable(radar.variables(3)); 
  grid = rain.grid_interop(1,:,:); 
  lat(:,:) = grid.lat; 
  lon(:,:) = grid.lon; 
  raindata(:,:) = double(rain.data(1,:,:)); 


folder = '/mnt/drive1/jj/nexrad/src/py/outData/';

file = fullfile(folder,'test.mat'); 
data = load(file); 

[lonGrid, latGrid] = meshgrid(data.lon,data.lat); 

latMin = min(data.lat); latMax = max(data.lat); 
lonMin = min(data.lon); lonMax = max(data.lon); 

% manual setup lon/lat range
lonMax = -88; 

% testing cleaning out the data
raindata(raindata == 0) = NaN; 
data.ref(data.ref == -9999) = NaN; 

data.cores(data.cores == 0) = NaN; 
data.cores_40 = double(data.cores_40); 
data.cores_40(data.cores_40 == 0) = NaN; 
data.cores_bg(data.cores_bg == 0) = NaN; 

ax1 = subplot(2,2,1);
m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
m_pcolor(lonGrid,latGrid,data.ref); shading flat; colorbar; 
hold on; 
m_coast('color','k');
m_grid('box','fancy','tickdir','in','xtick',[-104 -96 -88]); 
% axis([lonMin lonMax latMin latMax]); 
caxis([0 60]); 
title('Reflectivity (dBz)'); 
colormap(ax1,'jet');

ax2 = subplot(2,2,2);
m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
m_pcolor(lon,lat,raindata); shading flat; colorbar; 
hold on; 
m_coast('color','k');
m_grid('box','fancy','tickdir','in','xtick',[-104 -96 -88]); 
% axis([lonMin lonMax latMin latMax]); 
caxis([0 20]);
title('Stage 4 data');
colormap(ax2,'jet')

ax3 = subplot(2,2,3);
m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
m_pcolor(lonGrid,latGrid,data.cores_40); shading flat; colorbar; 
hold on; 
m_coast('color','k');
m_grid('box','fancy','tickdir','in','xtick',[-104 -96 -88]); 
% axis([lonMin lonMax latMin latMax]); 
caxis([0 1])
title('Cores (> 40 dBz)');
colormap(ax3,'cool')

ax4 = subplot(2,2,4);
m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
m_pcolor(lonGrid,latGrid,data.cores); shading flat; colorbar; 
hold on; 
m_coast('color','k');
m_grid('box','fancy','tickdir','in','xtick',[-104 -96 -88]); 
% axis([lonMin lonMax latMin latMax]); 
caxis([0 1])
title('Final Core Selection');
colormap(ax4,'cool')

suptitle('2011/04/25 @ 09H'); 

orient portrait
print('-dpng','-r500',sprintf('./images/multi_merge_09h.png')); 
close all; 

