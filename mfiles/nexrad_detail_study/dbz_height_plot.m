clear; 

% load test_grid.mat; 
load dbz_height_all_km.mat; 

dbzStep = 1;

minVal = floor(min(ratioArr(:)))./dbzStep; 
maxVal = floor(max(ratioArr(:)))./dbzStep + 1;  

dbzList = minVal:dbzStep:maxVal; 
[dbzGrid1, dbzGrid2] = meshgrid(dbzList,dbzList); 

temp = ratioArr; 
nanInd = (isnan(temp(:,1)) | isnan(temp(:,2))); 
temp(nanInd,:) = [];

tempInd = temp; 
tempInd = floor(temp./dbzStep)+1; 

dbzCorr = zeros(length(dbzList)); 

for i = 1:size(temp,1)
  dbzCorr(tempInd(i,2),tempInd(i,1)) = dbzCorr(tempInd(i,2),tempInd(i,1)) + 1; 
end

dbzCorr = dbzCorr./nansum(dbzCorr(:)); 


% subplot(2,1,2); 
close all; 
pcolor(dbzGrid1,dbzGrid2,dbzCorr); shading flat; h = colorbar; 
xlabel('2 km dBz'); 
ylabel('6 km dBz'); 
title('2D - Histogram (2km dBz vs 6km dBz)'); 
hold on; 
plot(dbzList,dbzList,'r--'); 
hold off; 
ylabel(h,'% values')
% print -djpeg99 hist_2d_plot_core.jpg

axis([0 50 0 50])
print -djpeg99 hist_2d_plot_all.jpg

%% cluster analysis

% k = 2; 
% [idx, centroid] = kmeans(temp, k, 'Distance','sqEuclidean','Replicates', 10, 'Display', 'iter');

% subplot(2,1,1);
% plot(temp(:,1),temp(:,2),'.'); 
% lsline; 
% % plot(temp(idx==1,1),temp(idx==1,2),'r.'); 
% % hold on; 
% % plot(temp(idx==2,1),temp(idx==2,2),'b.'); 
% % plot(temp(idx==3,1),temp(idx==3,2),'g.'); 
% % plot(temp(idx==4,1),temp(idx==4,2),'g.'); 
% % plot(centroid(:,1),centroid(:,2),'kx','markersize',15,'linewidth',5); 
% xlabel('2 km dBz'); 
% ylabel('6 km dBz'); 
% lsline
% title('2D - Histogram (2km dBz vs 6km dBz)'); 
% hold off; 


