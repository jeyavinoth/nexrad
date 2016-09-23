clear; 
figure(2)

load '../py/outData/20150919/nex_20150919_3.mat'


[lonGrid, latGrid] = meshgrid(lon,lat); 


latMin = min(lat); latMax = max(lat); 
lonMin = min(lon); lonMax = max(lon); 
selectRange = [latMin latMax lonMin lonMax]; 
lonRange = [lonMin lonMax]; 
latRange = [latMin latMax]; 
lonRange = [-92 -84]; 
latRange = [38 45]; 

temp = nan(size(allRef,2),size(allRef,3),size(allRef,1)); 

for i = 1:size(allRef,1)
  temp(:,:,i) = allRef(i,:,:); 
end

% plotting dbz profiles for ref > 40 dbz at 2km level 

ref_2km = squeeze(allRef(5,:,:)); 
radarSize = size(allRef,2); 
heightSize = size(allRef,1); 

hTemp = repmat(0:0.5:-0.5+heightSize/2,radarSize,1)'; 

  % find cores using Johnny's method of finding convection over 6km 
  temp = allRef(12:end,:,:); 
  temp40 = double(temp >= 20); 
  temp40 = squeeze(nansum(temp40,1)); 
  testCore = double(temp40 > 1); 

core40 = find(ref_2km > 40); 
[xAll,yAll] = ind2sub(size(ref),core40); 

selectRange = [-86 -85 40 41];

heightSelection = [1,2,4,6,8]; 
plotCnt = 1; 
for i = heightSelection 

  ind = i/0.5; 

  refHeight = squeeze(allRef(ind,:,:)); 

  ax1 = subplot(length(heightSelection),2,plotCnt); 
  pcolor(lonGrid,latGrid,refHeight); shading flat; colorbar; caxis([0 60])
  axis([lonRange latRange]); 
  title(sprintf('dbZ at %03.2fkm',i)); 
  colormap(ax1,'jet'); 

  plotCnt = plotCnt + 1; 

  ax1 = subplot(length(heightSelection),2,plotCnt); 
  contour(lonGrid,latGrid,refHeight,[20 40]); colorbar; 
  axis([lonRange latRange]); 
  title(sprintf('contours',i)); 
  colormap(ax1,'cool'); 
  
  plotCnt = plotCnt + 1; 
end

colormap(jet);

% orient portrait
% print ('-dpng','-r500','test.png');
