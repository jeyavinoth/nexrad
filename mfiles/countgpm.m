clear
clc 

gpmFolder = '/mnt/drive2/gpmdata/'; 
yySelect = 2015; 

selectionFile = './autoSelect.txt'; 

data = load('manualSelect.txt'); 

% selectRange = [29,47,-89,-72]; 
selectRange = [29,49,-126,-66]; 
latMin = selectRange(1);  
latMax = selectRange(2);  
lonMin = selectRange(3);  
lonMax = selectRange(4); 

totalFileCnt = 0; 
totalRegionCnt = 0; 
totalPrecipSigCnt = 0; 
totalPrecipBlobCnt = 0; 


latRange = selectRange(1):0.1:selectRange(2); 
lonRange = selectRange(3):0.1:selectRange(4); 
[latGrid, lonGrid] = meshgrid(latRange,lonRange); 

precipGridSum = zeros(size(latGrid)); 
precipGridCnt = zeros(size(latGrid)); 
totalGridCnt = zeros(size(latGrid)); 

% for dataLoop = 1:size(data,1)

for mmLoop = 1:12
  for ddLoop = 1:31
    % mmLoop = data(dataLoop,2); 
    % ddLoop = data(dataLoop,3); 

    extFolder = sprintf('%04d/%02d/%02d/radar/',yySelect,mmLoop,ddLoop); 
    folder = fullfile(gpmFolder,extFolder); 

    disp(folder); 
    
    if (exist(folder) == 0)
      continue; 
    end
  
    dirList = dir(fullfile(folder,'2B.GPM.DPRGMI.CORRA*.HDF5'));
    fileList = char({dirList.name}); 

    if (isempty(dirList))
      continue; 
    end

    for fileInd = 1:size(fileList,1)

      totalFileCnt = totalFileCnt + 1; 
      
      gpmFile = fileList(fileInd,:); 
      file = fullfile(folder,gpmFile); 

      gpm = readgpmfilename(file,'NS'); 

      ind = find(gpm.lat > latMin & gpm.lat < latMax & gpm.lon > lonMin & gpm.lon < lonMax); 
      [xind, yind] = find(gpm.lat > latMin & gpm.lat < latMax & gpm.lon > lonMin & gpm.lon < lonMax); 

      if (isempty(ind) | length(ind) < 5)
        continue; 
      end
      
      % plotting the gpmSection
      xmin = min(xind); 
      xmax = max(xind); 
      ymin = min(yind); 
      ymax = max(yind); 
      section.lat = gpm.lat(xmin:xmax,ymin:ymax); 
      section.lon = gpm.lon(xmin:xmax,ymin:ymax); 
      section.precip = gpm.precipRate(xmin:xmax,ymin:ymax); 
      section.allOne = double(section.lat);
      section.allOne(:) = 1; 
      section.lat = double(section.lat); 
      section.lon = double(section.lon); 
      section.precip = double(section.precip); 

      Fprecip = TriScatteredInterp(section.lat(:),section.lon(:),section.precip(:)); 
      filePrecip = Fprecip(latGrid,lonGrid); 

      Fcnt = TriScatteredInterp(section.lat(:),section.lon(:),section.allOne(:)); 
      fileCnt = Fcnt(latGrid,lonGrid);

      nanInd = isnan(fileCnt); 

      totalGridCnt(~nanInd) = totalGridCnt(~nanInd) + fileCnt(~nanInd); 

      nonNanInd = (~isnan(filePrecip)); 

      precipGridSum(nonNanInd) = precipGridSum(nonNanInd) + filePrecip(nonNanInd); 
      precipGridCnt = precipGridCnt + double(~isnan(filePrecip)); 

      totalRegionCnt = totalRegionCnt + 1; 

      precip = gpm.precipRate(ind); 
      precip(precip == 0) = NaN; 
      meanPrecip = nanmean(precip);

      precipRatio = length(find(precip > 1))/length(find(precip)); 

      if (meanPrecip <= 1 | precipRatio <= 0.03)
        continue; 
      end

      totalPrecipSigCnt = totalPrecipSigCnt + 1; 

      % clustering 
      precip = section.precip; 

      precipBin = double(precip >= 1); 
      group = bwlabel(precipBin); 

      uniVal = unique(group); 
      uniVal(uniVal == 0) = []; % get rid of zero value 

      uniCnt = 1; 
      maxSize = 0; 
      for uniInd = 1:length(uniVal)
        uniId = uniVal(uniInd); 
        obj = (group == uniId); 
        objSize = length(find(obj==1)); 
        temp = precip; 
        temp(~obj) = NaN; 

        [maxPrecipVal, maxPrecipInd] = nanmax(temp(:)); 

        if (objSize < 100) 
          group(group == uniId) = 0; 
          continue; 
        end

        if (objSize > maxSize)
          maxInd = uniCnt; 
          maxSize = objSize; 
        end

        olatmin = min(section.lat(obj)); 
        olatmax = max(section.lat(obj)); 
        olonmin = min(section.lon(obj)); 
        olonmax = max(section.lon(obj)); 

        omidlat = (olatmin + olatmax) / 2; 
        omidlon = (olonmin + olonmax) / 2; 

        uni(uniCnt).maxVal =  max(precip(obj)); 
        uni(uniCnt).objid = uniId; 
        uni(uniCnt).minlat = olatmin; 
        uni(uniCnt).maxlat = olatmax; 
        uni(uniCnt).minlon = olonmin; 
        uni(uniCnt).maxlon = olonmax; 
        uni(uniCnt).midlat = omidlat; 
        uni(uniCnt).midlon = omidlon; 
        uni(uniCnt).objSize = objSize; 

        uni(uniCnt).maxPrecipLat = section.lat(maxPrecipInd); 
        uni(uniCnt).maxPrecipLon = section.lon(maxPrecipInd); 

        uniCnt = uniCnt + 1; 

      end

      group(group == 0) = NaN; 

      if (maxSize ~= 0)
        totalPrecipBlobCnt = totalPrecipBlobCnt + 1; 
      end

      
      % ax1 = subplot(2,1,1); 
      % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin, latMax]);
      % m_pcolor(section.lon,section.lat,section.precip); shading flat; colorbar; caxis([0 12]);
      % m_coast('color','k'); 
      % m_grid('box','fancy','tickdir','out'); 
      % colormap(ax1,'jet'); 
      
      % ax2 = subplot(2,1,2); 
      % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin, latMax]);
      % m_pcolor(section.lon,section.lat,group); shading flat; colorbar; 
      % m_coast('color','k'); 
      % m_grid('box','fancy','tickdir','out'); 
      % colormap(ax2,'cool')
      % hold on; 
      % m_plot(uni(maxInd).midlon,uni(maxInd).midlat,'r*');
      % m_plot(uni(maxInd).maxPrecipLon,uni(maxInd).maxPrecipLat,'k*'); 
      % hold off; 
      
      % startTime= gpmFile(:,35:38); 
      % endTime = gpmFile(:,43:46);

      % minLat = min(section.lat(:)); 
      % maxLat = max(section.lat(:)); 
      % minLon = min(section.lon(:)); 
      % maxLon = max(section.lon(:)); 

      % title(sprintf('%04d/%02d/%02d %s-%s',yySelect,mmLoop,ddLoop,startTime,endTime)); 

      % print('-djpeg99',sprintf('./coreSelect/img_%02d_%02d_%s_%s.jpg',mmLoop,ddLoop,startTime,endTime));
      % close; 

      % fprintf(sfid,'%04d %02d %02d %8d %8.2f %8.2f %s %s %8.2f %8.2f %8.2f %8.2f %8.2f %8.2f\n',yySelect,mmLoop,ddLoop,length(precip),meanPrecip,precipRatio,startTime,endTime,minLat,maxLat,minLon,maxLon,uni(maxInd).maxPrecipLat,uni(maxInd).maxPrecipLon); 

    end
  end
end
disp(sprintf('Totat Files: %d (%8.2f)',totalFileCnt,100*totalFileCnt./totalFileCnt)); 
disp(sprintf('Total GPM cross Region: %d (%8.2f)',totalRegionCnt,100*totalRegionCnt./totalFileCnt)); 
disp(sprintf('Total Significant Preciptitaion: %d (%8.2f)',totalPrecipSigCnt,100*totalPrecipSigCnt./totalFileCnt)); 
disp(sprintf('Total Max Blob Size Cnt: %d (%8.2f)',totalPrecipBlobCnt,100*totalPrecipBlobCnt./totalFileCnt)); 
     
val = precipGridSum./precipGridCnt; 
% val(val==0) = NaN; 
m_proj('lambert','long',[lonMin lonMax],'lat',[latMin, latMax]);
m_pcolor(lonGrid,latGrid,val); shading flat; colorbar; 
caxis([0 3]); 
m_coast('color','k'); 
m_grid('box','fancy','tickdir','out'); 
colormap('jet'); 
title('Average Precipitation for Year 2015')

print -djpeg99 us_precip_gpm.jpg
close;

m_proj('lambert','long',[lonMin lonMax],'lat',[latMin, latMax]);
m_pcolor(lonGrid,latGrid,totalGridCnt); shading flat; colorbar; 
m_coast('color','k'); 
m_grid('box','fancy','tickdir','out'); 
colormap('jet'); 
title('Count of GPM crossings in US')

print -djpeg99 us_cnt_gpm.jpg
close;


