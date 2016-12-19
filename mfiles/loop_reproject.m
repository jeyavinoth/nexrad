clear
clc

dbzList = [10 15 20 25 30 35 40 45 50 55 60]; 
hList = 2:12; 
for dbzThres = dbzList 
  for hThres = hList 
    disp([dbzThres, hThres]); 
    reproject_mergeall
  end
end
