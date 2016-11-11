clear
close all 

make_16_gray

% inFolder = '/mnt/drive1/jj/nexrad/src/py/outData_single/20150410/'; 
inFolder = '/mnt/drive1/jj/nexrad/src/py/outData_single/20150410/'; 

timeStepList = 10:10/60:12; 

cnt = 0; 

for timeStep = timeStepList

  timeHr = floor(timeStep); 
  timeMin = round((timeStep - timeHr).*60); 

  if (timeMin == 0)
    timeMin = 60; 
    timeHr = timeHr - 1; 
  end
  filename = fullfile(inFolder,sprintf('nex_20150410_%02d_%02d.mat',timeHr,timeMin-1)); 

  if (exist(filename) == 0)
    disp(sprintf('Missing %s',filename)); 
    continue; 
  end
 
  cnt = cnt + 1; 

  data = load(filename); 

  nexData(cnt).allRef = double(data.allRef); 
  nexData(cnt).cores = data.cores; 
  nexData(cnt).cores3d = data.cores3d; 
  nexData(cnt).cores_bg = data.cores_bg; 
  nexData(cnt).cores_40 = data.cores_40; 
  nexData(cnt).lat = data.lat; 
  nexData(cnt).lon = data.lon; 
  nexData(cnt).timeStep = timeStep; 
  nexData(cnt).timeHr = timeHr; 
  nexData(cnt).timeMin = timeMin;

  data.allRef = double(data.allRef); 

  tempRef = squeeze(data.allRef(4,:,:)); 

  % tempRef = squeeze(data.allRef(10,:,:)); 
  
  [lonGrid, latGrid] = meshgrid(data.lon,data.lat); 
  latMin = min(data.lat); latMax = max(data.lat); 
  lonMin = min(data.lon); lonMax = max(data.lon); 

  nexData(cnt).lonGrid = lonGrid; 
  nexData(cnt).latGrid = latGrid; 
  nexData(cnt).cdtRange = [latMin, latMax, lonMin, lonMax]; 

      % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      % m_pcolor(lonGrid,latGrid,tempRef); shading flat; colorbar; 
      % hold on; 
      % m_usercoast('temp','color','k');
      % m_grid('box','fancy','tickdir','in'); 
      % caxis([0 40]);
      % title(sprintf('Reflectivity at 2km (%02d:%02d)',timeHr,timeMin-1)); 
      % colormap(map44)
  
  % imgFile = sprintf('./images_single/img_20150410_%02d_%02d.png',timeHr,timeMin); 
  % print('-dpng','-r500',imgFile); 
  % close

  disp(filename); 

end

save('./outData/nex_20150410.mat','nexData'); 
