clear; 
close all; 

make_16_gray

load ./outData/nex_20150410.mat; 

selectLat = 33.5; 
selectLon = -89.5; 

lat = nexData(1).lat; 
lon = nexData(1).lon; 
latGrid = nexData(1).latGrid; 
lonGrid = nexData(1).lonGrid; 
% tempRef = squeeze(nexData(1).allRef(4,:,:)); 

latMin = nexData(1).cdtRange(1); 
latMax = nexData(1).cdtRange(2); 
lonMin = nexData(1).cdtRange(3); 
lonMax = nexData(1).cdtRange(4); 

latInd = dsearchn(lat',selectLat); 
lonInd = dsearchn(lon',selectLon); 

% creating time series of reflectivity
tempRef = nan(size(nexData,2),size(nexData(1).allRef,1));
timeVal = [];
for timeLoop = 1:size(nexData,2)
  tempRef(timeLoop,:) = squeeze(nexData(timeLoop).allRef(:,latInd,lonInd)); 
  timeVal(timeLoop) = nexData(timeLoop).timeStep; 

  % ax(timeLoop) = subplot(2,size(nexData,2),timeLoop); 
  ax(timeLoop) = subplot(5,3,timeLoop); 
  m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
  m_pcolor(lonGrid,latGrid,squeeze(nexData(timeLoop).allRef(4,:,:))); shading flat; 
  hold on; 
  axis off; 
  % axis image; 
  m_plot(lonGrid(latInd,lonInd),latGrid(latInd,lonInd),'m*','markersize',5); 
  caxis([0 40]);
  colormap(ax(timeLoop),map44); 
end

timeGrid = repmat(timeVal',1,size(nexData(1).allRef,1)); 
altGrid = repmat(0.5:0.5:15,size(nexData,2),1); 


% ax2 = subplot(2,size(nexData,2),[size(nexData,2)+1 2*size(nexData,2)]); 
ax2 = subplot(5,3,[13 15]); 
pcolor(timeGrid,altGrid,tempRef); shading flat; 
colorbar; 
colormap(ax2,map44); caxis([0 40]); 

orient portrait
print ('-dpng','-r500','test.png'); 




