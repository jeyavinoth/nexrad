
close all; 
clear; 
load ratioArr.mat; 
edges = 0:0.02:0.8; 

% histogram(ratioArr(:,1),edges,'facecolor','r','edgecolor','none','facealpha',0.5); 
% hold on; 
% histogram(ratioArr(:,2),edges,'facecolor','b','edgecolor','none','facealpha',0.5); 
% legend('Vertical Core','GPM','Steiner'); 
% title('Vertical Core Ratio vs GPM Core Ratio')
% xlabel('Convective Core Pixel/Total Pixel'); 
% print -djpeg99 ./images_all/vertical_gpm_hist.jpg
% close all; 

% histogram(ratioArr(:,1),edges,'facecolor','r','edgecolor','none','facealpha',0.5); 
% hold on; 
% histogram(ratioArr(:,3),edges,'facecolor','b','edgecolor','none','facealpha',0.5); 
% legend('Vertical Core','Steiner'); 
% title('Vertical Core Ratio vs Steiner Core Ratio')
% xlabel('Convective Core Pixel/Total Pixel'); 
% print -djpeg99 ./images_all/vertical_steiner_hist.jpg
% close all 

%{
verticalRatio = ratioArr(:,1); 
gpmRatio = ratioArr(:,2); 
steinerRatio = ratioArr(:,3); 

nanInd = (isnan(verticalRatio) | isnan(gpmRatio) | isnan(steinerRatio)); 
verticalRatio(nanInd) = [];
gpmRatio(nanInd) = [];
steinerRatio(nanInd) = [];

plot(gpmRatio,verticalRatio,'*b'); 
hold on; 
plot(gpmRatio,steinerRatio,'*r'); 

maxRatio = max([gpmRatio; steinerRatio; verticalRatio]); 
minRatio = min([gpmRatio; steinerRatio; verticalRatio]); 

% x_test = min(gpmRatio):0.02:max(gpmRatio); 
x_test = minRatio:0.02:maxRatio; 
pv= polyfit(gpmRatio,verticalRatio,1); 
v1 = polyval(pv,x_test);
plot(x_test,v1,'b--'); 
hold on; 

ps= polyfit(gpmRatio,steinerRatio,1); 
s1 = polyval(ps,x_test); 
plot(x_test,s1,'r--'); 

plot(x_test,x_test,'k--'); 


ylabel('NexRAD Core Ratio'); 
xlabel('GPM Core Ratio'); 

legend('Vertical Core Method','Steiner Algorithm')
axis image; 

print -djpeg99 ./images_all/core_ratio_scatter.jpg
%}


verticalRatio = ratioArr(:,1); 
gpmRatio = ratioArr(:,2); 
steinerRatio = ratioArr(:,3); 

nanInd = (isnan(verticalRatio) | isnan(gpmRatio) | isnan(steinerRatio)); 
verticalRatio(nanInd) = [];
gpmRatio(nanInd) = [];
steinerRatio(nanInd) = [];

vDiff = verticalRatio - gpmRatio; 
sDiff = steinerRatio - gpmRatio; 

minDiff = min([vDiff; sDiff]); 
maxDiff = max([vDiff; sDiff]); 

edges = minDiff:0.05:maxDiff; 
histogram(vDiff,edges,'facecolor','r','facealpha',0.5,'edgecolor','none'); 
hold on; 
histogram(sDiff,edges,'facecolor','b','facealpha',0.5,'edgecolor','none'); 

xlabel('Difference Between Ratios')
legend('GPM Core Ratio - Vertical Core Ratio','GPM Core Ratio - Steiner Core Ratio','location','NorthWest')

print -djpeg99 ./images_all/ratio_diff.jpg

