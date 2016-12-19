clear; 
close all; 

% load cfad_all.mat; 
% load cfad_4_40.mat; 
% load cfad.mar
load cfad_stratiform_6_40.mat;  % 40 dbz @ 6km core selection

parpool('local',30); 
hStep = 0.5; 
dStep = 1; 

dGrid = ratioArr; 

% getting only profiles where 6km dbz > 2km dbz

% ind = find(ratioArr(12,:) > ratioArr(4,:));
% dGrid = ratioArr(:,ind); 

hList = 0+hStep/2:hStep:15-hStep/2;
hGrid = repmat(hList',1,size(dGrid,2)); 

dMin = floor(min(dGrid(:))./dStep); 
dMax = floor(max(dGrid(:))./dStep) + 1; 
dMax = floor(60./dStep) + 1; 
dList = dMin:dStep:dMax; 

[hOutGrid, dOutGrid] = meshgrid(hList,dList); 

hInd = floor(hGrid./hStep) + 1; 
dInd = floor(dGrid./dStep) + 1; 

cGrid = zeros(length(dList),length(hList)); 

disp('Starting Loop'); 

for hLoop = 1:length(hList)
  disp(sprintf('starting %d',hLoop)); 
  parfor dLoop = 1:length(dList)
    ind = find(dInd == dLoop & hInd == hLoop); 
    cGrid(dLoop,hLoop) = cGrid(dLoop,hLoop) + length(ind); 
    disp(dLoop); 
  end
  disp(hLoop); 
end

pcolor(dOutGrid,hOutGrid,cGrid); shading flat; colorbar; 
xlabel('dBz');
ylabel('Altitude');
print -djpeg99 cfad_stratiform.jpg


