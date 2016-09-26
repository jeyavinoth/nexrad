clear
clc 

gpmFolder = '/mnt/drive2/gpmdata/'; 
yySelect = 2015; 

logFile = './log_searchGPM.txt';
selectionFile = './selectedCases.txt'; 

fid = fopen(logFile,'w'); 
sfid = fopen(selectionFile,'w'); 

fprintf(fid,'yyyy mm dd #pixels mean_precip precip_ratio starttime endtime minLat maxLat minLon maxLon\n'); 

selectRange = [29,47,-89,-72]; 
latMin = selectRange(1);  
latMax = selectRange(2);  
lonMin = selectRange(3);  
lonMax = selectRange(4); 

for mmLoop = 1:12
  for ddLoop = 1:31

    extFolder = sprintf('%04d/%02d/%02d/radar/',yySelect,mmLoop,ddLoop); 
    folder = fullfile(gpmFolder,extFolder); 

    disp(folder); 
    
    if (exist(folder) == 0)
      fprintf(fid,'No folder found:%s\n',folder);
      continue; 
    end
  
    dirList = dir(fullfile(folder,'2B.GPM.DPRGMI.CORRA*.HDF5'));
    fileList = char({dirList.name}); 

    if (isempty(dirList))
      fprintf(fid,'No files found in the folder: %s\n',folder); 
      continue; 
    end

    for fileInd = 1:size(fileList,1)
      
      gpmFile = fileList(fileInd,:); 
      file = fullfile(folder,gpmFile); 

      gpm = readgpmfilename(file,'NS'); 

      ind = find(gpm.lat > latMin & gpm.lat < latMax & gpm.lon > lonMin & gpm.lon < lonMax); 
      [xind, yind] = find(gpm.lat > latMin & gpm.lat < latMax & gpm.lon > lonMin & gpm.lon < lonMax); 

      if (isempty(ind))
        continue; 
      end

      precip = gpm.precipRate(ind); 
      precip(precip == 0) = NaN; 
      meanPrecip = nanmean(precip);

      precipRatio = length(find(precip > 1))/length(find(precip)); 

      if (meanPrecip <= 1 | precipRatio <= 0.03)
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
   
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin, latMax]);
      m_pcolor(section.lon,section.lat,section.precip); shading flat; colorbar; caxis([0 12])
      m_coast('color','k'); 
      m_grid('box','fancy','tickdir','out'); 
      colormap(jet); 
      
      startTime= gpmFile(:,35:38); 
      endTime = gpmFile(:,43:46);

      minLat = min(section.lat(:)); 
      maxLat = max(section.lat(:)); 
      minLon = min(section.lon(:)); 
      maxLon = max(section.lon(:)); 

      print('-djpeg99',sprintf('./selectImages/img_%02d_%02d_%s_%s.png',mmLoop,ddLoop,startTime,endTime));
      close; 

      fprintf(sfid,'%04d %02d %02d %8d %8.2f %8.2f %s %s %8.2f %8.2f %8.2f %8.2f\n',yySelect,mmLoop,ddLoop,length(precip),meanPrecip,precipRatio,startTime,endTime,minLat,maxLat,minLon,maxLon); 

    end

  end
end

fclose(fid); 
fclose(sfid); 
