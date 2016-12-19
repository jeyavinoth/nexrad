
k = 4; 
[idx, centroid] = kmeans(allGrid', k, 'Distance','sqEuclidean','Replicates', 10, 'Display', 'iter');

[hOutGrid, dOutGrid] = meshgrid(hList,dList); 

subY = 2; 
subX = ceil(k/subY); 
for i = 1:k
  subplot(subX,subY,i);
  pcolor(dOutGrid,hOutGrid,reshape(centroid(i,:),length(dList),length(hList))); 
  shading flat; 
  title(sprintf('Cluster %d',i)); 
end
