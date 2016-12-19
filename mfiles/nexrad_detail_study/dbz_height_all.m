% % init
% clear; 
% close all; 
clear all; 
clear ratioArr

% setup_nctoolbox
make_16_gray


allCases = load('/home/jfbooth/jj/nexrad/src/mfiles/autoSelect.txt'); 
selectCases = unique(allCases,'rows'); 

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

    data = load(file); 

    tempArr = [];
    temp = squeeze(data.allRef(4,:)); 
    tempArr(:,1) = temp(:); 
    temp = squeeze(data.allRef(12,:)); 
    tempArr(:,2) = temp(:); 

    ratioArr = cat(1,ratioArr,tempArr); 

    disp(sprintf('Completed %s %02d %02d',dateString,timeStepHr,timeStepMin)); 
      
end %caseInd

ind = (isnan(ratioArr(:,1)) | isnan(ratioArr(:,2))); 
ratioArr(ind,:) = []; 

save('-v7.3','dbz_height_all_km.mat','ratioArr'); 
