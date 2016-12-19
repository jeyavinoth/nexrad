clear; 

load cfad.mat; 

hStep = 0.5; 
dStep = 1; 

dGrid = ratioArr; 

hList = 0+hStep/2:hStep:15-hStep/2;
% hGrid = repmat(hList',1,size(dGrid,2)); 
hInd = floor(hList./hStep) + 1; 

dMin = floor(min(dGrid(:))./dStep); 
dMax = floor(max(dGrid(:))./dStep) + 1; 
dList = dMin:dStep:dMax; 

% [hOutGrid, dOutGrid] = meshgrid(hList,dList); 

% hInd = floor(hGrid./hStep) + 1; 
% dInd = floor(dGrid./dStep) + 1; 


% for hLoop = 1:length(hList)
%   for dLoop = 1:length(dList)
%     ind = find(dInd == dLoop & hInd == hLoop); 
%     cGrid(dLoop,hLoop) = cGrid(dLoop,hLoop) + length(ind); 
%   end
% end

allGrid = zeros(length(hList)*length(dList),size(dGrid,2)); 
parfor i = 1:size(dGrid,2)
  temp = dGrid(:,i); 
  cGrid = zeros(length(dList),length(hList)); 
  dInd = floor(temp./dStep) + 1; 
  for j = 1:length(temp)
    if (isnan(temp(j)))
      continue; 
    end
    cGrid(dInd(j),hInd(j)) = cGrid(dInd(j),hInd(j)) + 1; 
    plot(cGrid(:))
  end
  allGrid(:,i) = cGrid(:); 
  disp(i); 
end

% k = 4; 
% [idx, centroid] = kmeans(allGrid, k, 'Distance','sqEuclidean','Replicates', 10, 'Display', 'iter');
