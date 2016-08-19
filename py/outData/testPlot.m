close; 
clear; 

% load ./nex_20110425_1.mat
load test.mat

%{
for i = 1:12

  x = squeeze(allRef(i,:,:)); 
  % imagesc(x); colorbar; caxis([0 60])
  imagesc(x>40); colorbar; 

  title(sprintf('height %2.1fkm',i/2));

  print('-dpng','-r500',sprintf('./testImages/dbz_%02d.png',i)); 
  close

end
%}

[lonGrid, latGrid] = meshgrid(lon,lat); 

latMin = min(lat); latMax = max(lat); 
lonMin = min(lon); lonMax = max(lon); 

temp = nan(size(allRef,2),size(allRef,3),size(allRef,1)); 

for i = 1:size(allRef,1)
  temp(:,:,i) = allRef(i,:,:); 
end

% plotting dbz profiles for ref > 40 dbz at 2km level 

ref_2km = squeeze(allRef(5,:,:)); 
radarSize = size(allRef,2); 
heightSize = size(allRef,1); 

hTemp = repmat(0:0.5:-0.5+heightSize/2,radarSize,1)'; 


core40 = find(ref_2km > 40); 
[xAll,yAll] = ind2sub(size(ref),core40); 

for i = 1:length(core40)

  ind = core40(i); 
  [x,y] = ind2sub(size(ref),ind); 

  if (~(y>600 & y<610 & x>500 & x<550))
    continue; 
  end
  
  % extract horizontal profile
  lon_profile = squeeze(allRef(:,x,:)); 
  lat_profile = squeeze(allRef(:,:,y));

  subplot(3,1,1); 
  pcolor(lonGrid,latGrid,ref_2km); shading flat; colorbar; caxis([0 60])
  hold on; 
  plot(lon(1:radarSize),lat(repmat(x,1,radarSize)),'r--');
  plot(lon(repmat(y,1,radarSize)),lat(1:radarSize),'r--');

  subplot(3,1,2); 
  lonTemp = repmat(lon,12,1); 
  pcolor(lonTemp,hTemp,lon_profile); shading flat; colorbar; caxis([0 60])

  subplot(3,1,3); 
  latTemp = repmat(lat,12,1); 
  pcolor(latTemp,hTemp,lat_profile); shading flat; colorbar; caxis([0 60])

  break; 
end

colormap(jet);

orient tall
print ('-dpng','-r500','test.png');

