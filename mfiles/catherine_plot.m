% init
clear; 
close all; 

setup_nctoolbox
make_16_gray

stageFolder = '/mnt/drive4/stage4/2015/';

selectCases = load('/mnt/drive1/jj/nexrad/src/mfiles/autoSelect.txt'); 
outputFolder = '/mnt/drive1/jj/nexrad/src/py/outData.marcus/'; 
outputFolder = '/mnt/drive1/jj/nexrad/src/py/outData.default/'; 

chooseDate = [2015,04,08]; 

xtickarray = [];  

% selectDate = [2015,09,19]; 
% cdtRange = [39,44,-93,-83]; 
% timeStepList = [03]; 
% xtickarray = [-92, -88, -84]; 

for caseInd = 1:size(selectCases,1)

    selectDate = [selectCases(caseInd,1),selectCases(caseInd,2),selectCases(caseInd,3)]; 

    if (~(selectDate(1) == chooseDate(1) && selectDate(2) == chooseDate(2) && selectDate(3) == chooseDate(3)))
      continue; 
    end

    dateString = sprintf('%04d%02d%02d',selectDate(1),selectDate(2),selectDate(3)); 
    % disp(dateString); 

    timeStart = selectCases(caseInd,7); 
    timeEnd = selectCases(caseInd,8); 


    timeStart = floor(timeStart/100) + (timeStart - floor(timeStart/100)*100)/60; 
    timeEnd = floor(timeEnd/100) + (timeEnd - floor(timeEnd/100)*100)/60; 

    if(timeStart > timeEnd & timeStart > 20)
      timeEnd = timeEnd + 24; 
    end

    if(timeStart > timeEnd & timeStart < 5) 
      timeStart = timeStart - 24; 
    end

    timeStepList = ceil(timeStart):floor(timeEnd); 

    originLat = selectCases(caseInd,13); 
    originLon = selectCases(caseInd,14); 
    cdtRange = [originLat-2, originLat+2, originLon-2, originLon+2]; 
    xtickarray = floor(originLon-2):2:ceil(originLon+2);  

    for timeStep = timeStepList

      stageFile = fullfile(stageFolder,sprintf('ST4.%s%02d.01h',dateString,timeStep)); 
      folder = sprintf('%s%s/',outputFolder,dateString);
      file = fullfile(folder,sprintf('nex_%s_%02d.mat',dateString,timeStep)); 

      if (exist(stageFile) == 0 || exist(file) == 0)
        disp(sprintf('No stage file found for %s @ %02d',dateString,timeStep)); 
        continue; 
      end

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

      ref_surf = squeeze(data.allRef(4,:,:)); 
      ref_surf(ref_surf == -9999) = NaN;  

      % ref_surf = squeeze(nanmax(double(data.allRef),[],1)); 


      % data.cores(data.cores == 0) = NaN; 
      data.cores_40 = double(data.cores_40); 
      % data.cores_40(data.cores_40 == 0) = NaN; 
      % data.cores_bg(data.cores_bg == 0) = NaN; 

      % find cores using Johnny's method of finding convection over 6km 
      temp = data.allRef(12:end,:,:); 
      temp40 = double(temp >= 20); 
      temp40 = squeeze(nansum(temp40,1)); 
      testCore = double(temp40 > 1); 

      % % core selectoin using column 2km to 4km (have to double check this)
      % temp = data.allRef(4:12,:,:); 
      % tempCol = double(temp<40); 
      % tempCol = squeeze(nansum(tempCol,1)); 
      % testCore = double(tempCol == 0);
      % nanInd = double(isnan(temp)); 
      % nanSum = squeeze(sum(nanInd));
      % nanFinal = (nanSum == size(temp,1)); 
      % testCore(nanFinal) = NaN; 

      ax1 = subplot(2,2,1);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(lonGrid,latGrid,ref_surf); shading flat; colorbar; 
      hold on; 
      m_coast('color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 60]); 
      title('Ref @ 2km (dBz)'); 
      colormap(ax1,'jet');

      ax2 = subplot(2,2,2);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,precipRate); shading flat; colorbar; 
      hold on; 
      m_coast('color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 12]);
      title('GPM Precip Rate [mm/hr]');
      colormap(ax2,map44)

      ax3 = subplot(2,2,3);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(lon,lat,raindata); shading flat; colorbar; 
      hold on; 
      m_coast('color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 12])
      title('Stage 4 [mm/hr]');
      colormap(ax3,map44)


      ax4 = subplot(2,2,4);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(lonGrid,latGrid,testCore); shading flat; colorbar; 
      hold on; 
      m_coast('color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 1])
      title('Core using vertical profile');
      colormap(ax4,'cool')

      % ax5 = subplot(2,3,5);
      % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      % m_pcolor(gpmLon,gpmLat,precipType); shading flat; colorbar; 
      % hold on; 
      % m_coast('color','k');
      % m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      % caxis([1 2])
      % title('Precip Type from GPM');
      % colormap(ax5,'cool')


      % ax6 = subplot(2,3,6);
      % m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      % m_pcolor(lonGrid,latGrid,data.cores); shading flat; colorbar; 
      % hold on; 
      % m_coast('color','k');
      % m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      % caxis([0 1])
      % title('Steiner* core selection');
      % colormap(ax6,'cool')

      suptitle(sprintf('%d/%02d/%02d @ %02dH',selectDate(1),selectDate(2),selectDate(3),timeStep)); 

      orient portrait

      if (exist(sprintf('./images/%s',dateString)) == 0)
        mkdir('./images/',dateString); 
      end
      print('-dpng','-r500',sprintf('./images/%s/img_4frame_%s_%02d.png',dateString,dateString,timeStep)); 

      disp(sprintf('Completed %s',dateString)); 
      
      close all; 
   end 
end
