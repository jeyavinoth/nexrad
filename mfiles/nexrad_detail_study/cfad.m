% % init
% clear; 
% close all; 
clear all; 
clear ratioArr

% setup_nctoolbox
make_16_gray

% stageFolder = '/mnt/drive4/stage4/2015/';

allCases = load('/home/jfbooth/jj/nexrad/src/mfiles/autoSelect.txt'); 
selectCases = unique(allCases,'rows'); 

xtickarray = [];  

plotFlag = 0; % 0 => dont plot, 1 => plot figures
dbzThres = 40; % dbz value about what height 
hThres = 6; % above what height must I check the dbz value  

% ratioArr = nan(size(selectCases,1),3); 
ratioArr = [];

for caseInd = 1:size(selectCases,1)

    selectDate = [selectCases(caseInd,1),selectCases(caseInd,2),selectCases(caseInd,3)]; 
    dateString = sprintf('%04d%02d%02d',selectDate(1),selectDate(2),selectDate(3)); 
    % disp(dateString); 

    startTime = selectCases(caseInd,15); 
    endTime = selectCases(caseInd,16); 
    
    startTime = floor(startTime/100) + (startTime - floor(startTime/100)*100)/60; 
    endTime = floor(endTime/100) + (endTime - floor(endTime/100)*100)/60; 

    startHr = floor(startTime./100); 
    startMin = (startTime - startHr).*60; 

    endHr = floor(endTime./100); 
    endMin = (endTime - endHr).*60; 

    if(startTime > endTime)
      continue; 
    end

    timeStep = (startTime + endTime)/2; 
    timeStepHr = floor(timeStep); 
    timeStepMin = floor((timeStep - floor(timeStep)).*60); 

    yyLoop = selectCases(caseInd,1); 
    mmLoop = selectCases(caseInd,2); 
    ddLoop = selectCases(caseInd,3); 

    originLat = selectCases(caseInd,13); 
    originLon = selectCases(caseInd,14); 
    cdtRange = [originLat-2, originLat+2, originLon-2, originLon+2]; 
    xtickarray = floor(originLon-2):2:ceil(originLon+2);  

    folder = sprintf('/home/jfbooth/jj/nexrad/src/py/outData/%s/',dateString);
    file = fullfile(folder,sprintf('nex_%s_%02d%02d.mat',dateString,timeStepHr,timeStepMin)); 

    if (exist(file) == 0)
      disp(sprintf('No NexRAD processed file found for %s @ %02d:%02d',dateString,timeStepHr,timeStepMin)); 
      continue; 
    end
    
    try 
      gpmData = readgpm(selectDate(1),selectDate(2),selectDate(3),timeStep,'NS'); 
    catch
      disp(sprintf('No GPM file found for %04d/%02d/%02d @ %02d:%02d',selectDate(1),selectDate(2),selectDate(3),timeStepHr,timeStepMin)); 
      continue; 
    end

    gpmLat = gpmData.lat; 
    gpmLon = gpmData.lon; 
    precipRate = gpmData.precipRate; 
    precipType = gpmData.precipType; % 1- startiform, 2 -convective, 3 - other
    precipType = floor(precipType); 

    % getting rid of other precipitations except startiform n convective
    precipType (precipType ~= 1 & precipType ~= 2) = NaN; 
   
    % resetting the cores from 1/2 to 0/1
    gpmCore = precipType; 
    gpmCore (gpmCore == 1) = 0; 
    gpmCore (gpmCore == 2) = 1; 
    
    data = load(file); 

    [lonGrid, latGrid] = meshgrid(data.lon,data.lat); 

    latMin = min(data.lat); latMax = max(data.lat); 
    lonMin = min(data.lon); lonMax = max(data.lon); 
    
    latMin = cdtRange(1); latMax = cdtRange(2); 
    lonMin = cdtRange(3); lonMax = cdtRange(4); 

    % testing cleaning out the data
    data.ref(data.ref == -9999) = NaN; 

    ref_2km = squeeze(data.allRef(4,:,:)); 
    ref_2km(ref_2km == -9999) = NaN;  

    ref_2km = squeeze(nanmax(double(data.allRef),[],1)); 

    data.cores_40 = double(data.cores); 

    % find cores using Johnny's method of finding convection over 6km 
    hThresInd = floor(hThres/0.5); 

    temp = data.allRef(hThresInd:end,:,:); 
    temp_dbz = double(temp >= dbzThres); 
    temp_dbz = squeeze(nansum(temp_dbz,1)); 
    testCore = double(temp_dbz > 1); 

    temp = data.allRef(:,:,:); 
    tempAll = double(temp > 0); 
    tempAll = squeeze(nansum(tempAll,1)); 
    stratInd = double(tempAll > 0); 

    % re-project
    testCore(~stratInd) = NaN; 
    Fnex = TriScatteredInterp(lonGrid(:),latGrid(:),testCore(:)); 
    nexCore = Fnex(double(gpmLon),double(gpmLat)); 

    tempCore = data.cores; 
    tempCore(~stratInd) = NaN; 
    Fsteiner = TriScatteredInterp(lonGrid(:),latGrid(:),tempCore(:)); 
    steinCore = Fsteiner(double(gpmLon),double(gpmLat)); 

    nexRatio = length(find(nexCore == 1))/length(find(~isnan(nexCore))); 
    gpmRatio = length(find(gpmCore == 1))/length(find(~isnan(gpmCore))); 
    steinRatio = length(find(steinCore == 1))/length(find(~isnan(steinCore))); 

    nexSum = length(find(nexCore == 1)); 
    gpmSum = length(find(gpmCore == 1)); 
    steinSum = length(find(steinCore == 1)); 
    
    nexSize = length(find(~isnan(nexCore))); 
    nex.totalSize = nexSize; 

    gpmSize = length(find(~isnan(gpmCore))); 
    gpm.totalSize = gpmSize; 

    steinerSize = length(find(~isnan(steinCore))); 
    steiner.totalSize = steinerSize; 

    [nexX nexY] = find(testCore == 1); 
    nexXY = find(testCore == 0); 

    if (isempty(nexXY))
      continue; 
    end

    tempArr = [];
    % temp = squeeze(data.allRef(4,nexX(:),nexY(:))); 
    tempArr = squeeze(data.allRef(:,[nexXY(:)])); 
    ratioArr = cat(2,ratioArr,tempArr); 

    if (plotFlag == 1) 

      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_gshhs_h('save','temp'); 
      close all; 

      ax1 = subplot(2,3,1);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,precipRate); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 12]);
      title('GPM Precip Rate [mm/hr]');
      colormap(ax1,map44)

      ax2 = subplot(2,3,2);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,gpmCore); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 1])
      title('Precip Type from GPM');
      colormap(ax2,'cool')
      
      ax3 = subplot(2,3,3);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,data.cores3d); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 12])
      title('40dbz from 2 to 6km');
      colormap(ax3,map44)

      ax4 = subplot(2,3,4);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,nexCore); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 1])
      title('Core using vertical profile');
      colormap(ax4,'cool')

      ax5 = subplot(2,3,5);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(gpmLon,gpmLat,steinCore); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 1])
      title('Steiner* core selection');
      colormap(ax5,'cool')
      
      ax6 = subplot(2,3,6);
      m_proj('lambert','long',[lonMin lonMax],'lat',[latMin latMax]); 
      m_pcolor(lonGrid,latGrid,ref_2km); shading flat; colorbar; 
      hold on; 
      m_usercoast('temp','color','k');
      m_grid('box','fancy','tickdir','in','xtick',xtickarray); 
      caxis([0 60]); 
      title('Ref @ 2km (dBz)'); 
      colormap(ax6,'jet');

      titleStr = sprintf('%d/%02d/%02d @ %02dH',selectDate(1),selectDate(2),selectDate(3),timeStep);
      suptitle(titleStr); 

      orient portrait
      
      print('-dpng','-r500',sprintf('./images_all/reprojection_%s_%02d.png',dateString,timeStep)); 
    end %if plotFlag

      disp(sprintf('Completed %s %02d %02d',dateString,timeStepHr,timeStepMin)); 
      
      close all; 
end %caseInd

save('-v7.3','cfad_startiform_6_40.mat','ratioArr'); 
