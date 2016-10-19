load ('blobCnt.mat'); 

nCnts = nex.objSize; 
sCnts = steiner.objSize; 
gCnts = gpm.objSize; 

nCnts(nCnts <= 3) = [];
sCnts(sCnts <= 3) = [];
gCnts(gCnts <= 3) = [];


maxCnt = max([nCnts, sCnts, gCnts]); 
edges = 0:1:maxCnt; 
nh =  histogram(nCnts,edges,'facecolor','r','facealpha',0.5,'edgecolor','none');
nY = nh.Values; 
nY = nY./sum(nY); 
nX = nh.BinEdges; 
nX1 = nX; 
nX2 = circshift(nX,-1);  
nX = (nX1 + nX1)./2; 
nX(end) = [];

sh =  histogram(sCnts,edges,'facecolor','b','facealpha',0.5,'edgecolor','none');
sY = sh.Values; 
sY = sY./sum(sY); 
sX = sh.BinEdges; 
sX1 = sX; 
sX2 = circshift(sX,-1);  
sX = (sX1 + sX1)./2; 
sX(end) = [];

gh =  histogram(gCnts,edges,'facecolor','b','facealpha',0.5,'edgecolor','none');
gY = gh.Values; 
gY = gY./sum(gY); 
gX = gh.BinEdges; 
gX1 = gX; 
gX2 = circshift(gX,-1);  
gX = (gX1 + gX1)./2; 
gX(end) = [];


close;

plot(nX,nY,'r');
hold on; 
plot(sX,sY,'b'); 
plot(gX,gY,'k'); 
xlim([0 50]); 

title('Normalized Histogram of Precip Blob Size'); 
xlabel('Precipitation Blob Size'); 
legend('Vertical Core','Steiner','GPM')

print -djpeg99 ./images_all/blob_size.jpg
close; 

edges = 0:0.1:maxCnt; 

distType = 'gamma'; 

npd = fitdist(nCnts',distType); 
nY = pdf(npd,edges); 

spd = fitdist(sCnts',distType); 
sY = pdf(spd,edges); 

gpd = fitdist(gCnts',distType); 
gY = pdf(gpd,edges); 

plot(edges,nY,'r');
hold on; 
plot(edges,sY,'b'); 
plot(edges,gY,'k'); 
xlim([0 50]); 

title('Gamma Distribution Fit for Precip Blob Size'); 
xlabel('Precipitation Blob Size'); 
legend('Vertical Core','Steiner','GPM')
print -djpeg99 ./images_all/blob_size_gamma.jpg
