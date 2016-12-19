clear
clc

dbzList = [10 15 20 25 30 35 40 45 50 55 60]; 
heightList = 2:12; 

for dbzLoop = 1:length(dbzList) 
  dbzThres = dbzList(dbzLoop);
  for hLoop = 1:length(heightList) 
    hThres = heightList(hLoop); 
    inFile = sprintf('./ratioArrays/bak/ratio_%d_%d.mat',dbzThres,hThres); 
    data = load (inFile); 
     
    nexSum = data.ratioArr(:,1); 
    gpmSum = data.ratioArr(:,2); 
    steinSum = data.ratioArr(:,3); 

    nexGrid(dbzLoop,hLoop) = nansum(nexSum);  
    gpmGrid(dbzLoop,hLoop) = nansum(gpmSum);  
    steinGrid(dbzLoop,hLoop) = nansum(steinSum);  
         
    disp([dbzThres, hThres]); 
  end
end

[dbzGrid, hGrid] = meshgrid(dbzList,heightList); 
