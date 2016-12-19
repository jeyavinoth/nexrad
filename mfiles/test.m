clear
clc

dbzList = [10 15 20 25 30 35 40 45 50 55 60]; 
heightList = 2:12; 
for dbzLoop = 1:length(dbzList) 
  dbzThres = dbzList(dbzLoop);
  for hLoop = 1:length(heightList) 
    hThres = heightList(hLoop); 
    inFile = sprintf('./ratioArrays/ratio_%d_%d.mat',dbzThres,hThres); 
    load (inFile)
    disp([dbzThres, hThres]); 
  end
end
