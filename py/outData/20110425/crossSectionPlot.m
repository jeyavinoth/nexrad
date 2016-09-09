close; 
clear; 

load ./nex_20110425_1.mat
% load test.mat

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

% finding the cores of the data
cores3d_test = zeros(size(allRef,2),size(allRef,3));
allRef(allRef == -9999) = NaN; 
for i = 1:size(allRef,2)
  for j = 1:size(allRef,3)
    profile = allRef(:,i,j); 
    profile = profile(5:12);

    noVal = 0; 
    haveVal = 0; 
    for k = 1:length(profile)

      if (isnan(profile(k)))
        continue; 
      end

      if (profile(k) < 40)
        noVal = 1; 
      else
        haveVal = 1; 
      end
    end

    if (noVal ~= 1 & haveVal == 1)
      cores3d_test(i,j) = 1; 
    end

  end
end


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

  % if (~(latGrid(ind)>37.2 & latGrid(ind)<37.3 & lonGrid(ind)>-92 & lonGrid(ind)<-91))
  %   continue; 
  % end

  selectRange = [-93.33 -93.31 35.29 35.31];
  if (~(latGrid(ind)>selectRange(3) & latGrid(ind)<selectRange(4) & lonGrid(ind)>selectRange(1) & lonGrid(ind)<selectRange(2)))
    continue; 
  end
  
  % extract horizontal profile
  lon_profile = squeeze(allRef(:,x,:)); 
  lat_profile = squeeze(allRef(:,:,y));

  % temp lat & lon range 
  lonRange = [-94 -93]; 
  latRange = [35 36]; 

  % lonRange = [-95 -90];
  % latRange = [35 40]; 

  lonRange = [min(lonGrid(:)) max(lonGrid(:))]; 
  latRange = [min(latGrid(:)) max(latGrid(:))]; 

  ax1 = subplot(2,2,1); 
  pcolor(lonGrid,latGrid,ref_2km); shading flat; colorbar; caxis([0 60])
  hold on; 
  plot(lon(1:radarSize),lat(repmat(x,1,radarSize)),'r--');
  plot(lon(repmat(y,1,radarSize)),lat(1:radarSize),'r--');
  axis([lonRange latRange]); 
  title('Reflectivity at 2km')
  xlabel('Longitude'); 
  ylabel('Latitude'); 
  colormap(ax1,'jet'); 

  ax2 = subplot(2,2,2);
  latTemp = repmat(lat,heightSize,1); 
  pcolor(hTemp',latTemp',lat_profile'); shading flat; colorbar; caxis([0 60])
  hold on; 
  plot(1:heightSize,repmat(latGrid(ind),1,heightSize),'k--'); 
  axis([min(hTemp(:)) max(hTemp(:)) latRange]); 
  title('Refectivity Cross Section')
  xlabel('Height'); 
  ylabel('Latitude'); 
  colormap(ax2,'jet'); 

  ax3 = subplot(2,2,3);
  lonTemp = repmat(lon,heightSize,1); 
  pcolor(lonTemp,hTemp,lon_profile); shading flat; colorbar; caxis([0 60])
  hold on; 
  plot(repmat(lonGrid(ind),1,heightSize),1:heightSize,'k--'); 
  axis([lonRange min(hTemp(:)) max(hTemp(:))]); 
  title('Refectivity Cross Section')
  xlabel('Longitude'); 
  ylabel('Height'); 
  colormap(ax3,'jet'); 

  ax4 = subplot(2,2,4); 
  pcolor(lonGrid,latGrid,cores3d); shading flat; colorbar; caxis([0 1])
  hold on; 
  plot(lon(1:radarSize),lat(repmat(x,1,radarSize)),'r--');
  plot(lon(repmat(y,1,radarSize)),lat(1:radarSize),'r--');
  axis([lonRange latRange]); 
  title('Cores using 40dbz columns')
  xlabel('Longitude'); 
  ylabel('Latitude'); 
  colormap(ax4,'cool');

  break; 
end

colormap(jet);

orient portrait
print ('-dpng','-r500','test.png');
