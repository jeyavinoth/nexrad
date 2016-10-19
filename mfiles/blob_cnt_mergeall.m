% init
clear; 
close all; 

setup_nctoolbox
make_16_gray

stageFolder = '/mnt/drive4/stage4/2015/';

selectCases = load('/mnt/drive1/jj/nexrad/src/mfiles/autoSelect.txt'); 

xtickarray = [];  

% selectDate = [2015,09,19]; 
% cdtRange = [39,44,-93,-83]; 
% timeStepList = [03]; 
% xtickarray = [-92, -88, -84]; 

ratioArr = nan(size(selectCases,1),3); 

nexCnt = 1; 
gpmCnt = 1; 
steinerCnt = 1; 

for caseInd = 1:size(selectCases,1)

    selectDate = [selectCases(caseInd,1),selectCases(caseInd,2),selectCases(caseInd,3)]; 
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
      folder = sprintf('/mnt/drive1/jj/nexrad/src/py/outData/%s/',dateString);
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

      ref_surf = squeeze(nanmax(double(data.allRef),[],1)); 


      % data.cores(data.cores == 0) = NaN; 
      data.cores_40 = double(data.cores); 
      % data.cores_40(data.cores_40 == 0) = NaN; 
      % data.cores_bg(data.cores_bg == 0) = NaN; 

      % find cores using Johnny's method of finding convection over 6km 
      temp = data.allRef(12:end,:,:); 
      temp40 = double(temp >= 20); 
      temp40 = squeeze(nansum(temp40,1)); 
      testCore = double(temp40 > 1); 

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
      gpmRatio = length(find(precipType == 2))/length(find(~isnan(precipType))); 
      steinRatio = length(find(steinCore == 1))/length(find(~isnan(steinCore))); 
      
      nexSize = length(find(~isnan(nexCore))); 
      gpmSize = length(find(~isnan(precipType))); 
      steinerSize = length(find(~isnan(steinCore))); 

      %% find nexRad core blobs
      nexCore = (nexCore ==1); 
      group = bwlabel(nexCore); 
      uniVal = unique(group); 
      uniVal(uniVal == 0) = []; % get rid of zero value 
      totalSize = length(find(~isnan(nexCore))); 
      for uniInd = 1:length(uniVal)
        uniId = uniVal(uniInd); 
        obj = (group == uniId); 
        objSize = length(find(obj==1)); 
        nex.totalSize(nexCnt) = nexSize; 
        nex.objSize(nexCnt) = objSize; 
        nexCnt = nexCnt + 1; 
      end

      %% find gpm core blobs
      gpmCore = double(precipType==2); 
      gpmCore = (gpmCore == 1); 
      group = bwlabel(gpmCore); 
      uniVal = unique(group); 
      uniVal(uniVal == 0) = []; % get rid of zero value 
      for uniInd = 1:length(uniVal)
        uniId = uniVal(uniInd); 
        obj = (group == uniId); 
        objSize = length(find(obj==1)); 
        gpm.totalSize(gpmCnt) = gpmSize; 
        gpm.objSize(gpmCnt) = objSize; 
        gpmCnt = gpmCnt + 1; 
      end

      %% find steiner core blobs
      steinCore = (steinCore == 1); 
      group = bwlabel(steinCore); 
      uniVal = unique(group); 
      uniVal(uniVal == 0) = []; % get rid of zero value 
      for uniInd = 1:length(uniVal)
        uniId = uniVal(uniInd); 
        obj = (group == uniId); 
        objSize = length(find(obj==1)); 
        steiner.totalSize(steinerCnt) = steinerSize; 
        steiner.objSize(steinerCnt) = objSize; 
        steinerCnt = steinerCnt + 1; 
      end

      ratioArr(caseInd,1) = nexRatio; 
      ratioArr(caseInd,2) = gpmRatio; 
      ratioArr(caseInd,3) = steinRatio; 


      disp(sprintf('Completed %s',dateString)); 
      
      close all; 
   end 
end

save('blobCnt.mat','nex','steiner','gpm'); 
