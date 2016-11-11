function main
close all; 
clear all; 

[la_img, la_map] = imread('leftArrow.png'); 
[ra_img, ra_map] = imread('rightArrow.png'); 
[ua_img, ua_map] = imread('upArrow.png'); 
[da_img, da_map] = imread('downArrow.png'); 

% push buttons
f = figure('ToolBar','none');
t = uitoolbar(f); 
la = uipushtool(t,'TooltipString','Decrement Time Step','ClickedCallback',@(obj,event)inc_timestep(obj,event,-1,0),'separator','on'); 
ra = uipushtool(t,'TooltipString','Decrement Time Step','ClickedCallback',@(obj,event)inc_timestep(obj,event,+1,0),'separator','on'); 
da = uipushtool(t,'TooltipString','Decrement Time Step','ClickedCallback',@(obj,event)inc_timestep(obj,event,0,-0.5),'separator','on'); 
ua = uipushtool(t,'TooltipString','Decrement Time Step','ClickedCallback',@(obj,event)inc_timestep(obj,event,0,+0.5),'separator','on'); 
la.CData = la_img; 
ra.CData = ra_img; 
ua.CData = ua_img; 
da.CData = da_img; 

% make_16_gray
load ./outData/nex_20150410.mat; 

cursor_handle = []; 

lat = nexData(1).lat; 
lon = nexData(1).lon; 
latGrid = nexData(1).latGrid; 
lonGrid = nexData(1).lonGrid; 

latMin = nexData(1).cdtRange(1); 
latMax = nexData(1).cdtRange(2); 
lonMin = nexData(1).cdtRange(3); 
lonMax = nexData(1).cdtRange(4); 

initTime = 1; 
initHeight = 2; 
ref = squeeze(nexData(initTime).allRef(initHeight*2,:,:));

ax1 = subplot(2,3,2); 
pcolor(lonGrid,latGrid,ref); shading flat; 
axis([lonMin, lonMax, latMin, latMax]); 
s = sprintf('2015/04/10 @ %02d:%02d @ %04.1fkm',nexData(initTime).timeHr,nexData(initTime).timeMin,initHeight); 
title(s);
caxis([0 40])
colorbar; colormap(jet); 

hold on; 
cursor_handle = plot(0,0,'k+','markersize',15,'visible','off'); 
hold off; 
    

  function inc_timestep(src,event,incVal,incHeight)
    initTime = initTime + incVal; 
    initHeight = initHeight + incHeight; 
    if (initTime >= size(nexData,2))
      initTime = size(nexData,2); 
    end
    if (initTime <= 1)
      initTime = 1; 
    end

    if (initHeight <= 0.5)
      initHeight = 0.5; 
    end

    if (initHeight >= 15)
      initHeight = 15; 
    end

    ref = squeeze(nexData(initTime).allRef(initHeight*2,:,:));
    ax1 = subplot(2,3,2); 
    pcolor(ax1,lonGrid,latGrid,ref); shading flat; 
    colorbar; colormap(jet); 
    s = sprintf('2015/04/10 @ %02d:%02d @ %04.1fkm',nexData(initTime).timeHr,nexData(initTime).timeMin,initHeight); 
    caxis([0 40])
    title(s);
    hold on; 
    cursor_handle = plot(0,0,'k+','markersize',15,'visible','off'); 
    hold off; 
    
    cP = get(ax1,'Currentpoint');
    x = cP(1,1);
    y = cP(1,2);
    set(cursor_handle,'Xdata',x,'Ydata',y,'visible','on')
    
    set(gca,'ButtonDownFcn', @mouseclick_callback)
    set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)
      
    latInd = dsearchn(lat',y); 
    lonInd = dsearchn(lon',x); 
    for timeLoop = 1:size(nexData,2)
      tempRef(timeLoop,:) = squeeze(nexData(timeLoop).allRef(:,latInd,lonInd)); 
      timeVal(timeLoop) = nexData(timeLoop).timeStep; 
    end

    timeGrid = repmat(timeVal',1,size(nexData(initTime).allRef,1)); 
    altGrid = repmat(0.5:0.5:15,size(nexData,2),1); 

    ax2 = subplot(2,3,3); 
    pcolor(timeGrid,altGrid,tempRef); shading flat; 
    colorbar; colormap(jet); 
    set(ax2,'Xdir','reverse'); 
    caxis([0 40])
    xlabel('Time [hrs]'); 
    ylabel('Height [km]'); 

    ax_horz = subplot(2,3,5); 
    tempY = repmat(lat',1,30); 
    tempX = repmat(0.5:0.5:15,400,1); 
    ref = squeeze(nexData(initTime).allRef(:,latInd,:)); 
    pcolor(tempY,tempX,ref'); shading flat; 

    ax_horz = subplot(2,3,1); 
    tempY = repmat(lon',1,30); 
    tempX = repmat(0.5:0.5:15,400,1); 
    ref = squeeze(nexData(initTime).allRef(:,:,lonInd)); 
    pcolor(tempX,tempY,ref'); shading flat; 
      
    
  end

  function mouseclick_callback(gcbo,eventdata)
      % the arguments are not important here, they are simply required for
      % a callback function. we don't even use them in the function,
      % but Matlab will provide them to our function, we we have to
      % include them.
      %
      % first we get the point that was clicked on

      cP = get(ax1,'Currentpoint');
      x = cP(1,1);
      y = cP(1,2);
      
      set(cursor_handle,'Xdata',x,'Ydata',y,'visible','on')

      latInd = dsearchn(lat',y); 
      lonInd = dsearchn(lon',x); 
      for timeLoop = 1:size(nexData,2)
        tempRef(timeLoop,:) = squeeze(nexData(timeLoop).allRef(:,latInd,lonInd)); 
        timeVal(timeLoop) = nexData(timeLoop).timeStep; 
      end

      timeGrid = repmat(timeVal',1,size(nexData(initTime).allRef,1)); 
      altGrid = repmat(0.5:0.5:15,size(nexData,2),1); 

      ax2 = subplot(2,3,3); 
      pcolor(timeGrid,altGrid,tempRef); shading flat; 
      colorbar; colormap(jet); 
      set(ax2,'Xdir','reverse'); 
      caxis([0 40])
      xlabel('Time [hrs]'); 
      ylabel('Height [km]'); 

      ax_horz = subplot(2,3,5); 
      tempY = repmat(lat',1,30); 
      tempX = repmat(0.5:0.5:15,400,1); 
      ref = squeeze(nexData(initTime).allRef(:,latInd,:)); 
      pcolor(tempY,tempX,ref'); shading flat; 

      ax_vert = subplot(2,3,1); 
      tempY = repmat(lon',1,30); 
      tempX = repmat(0.5:0.5:15,400,1); 
      ref = squeeze(nexData(initTime).allRef(:,:,lonInd)); 
      pcolor(tempX,tempY,ref'); shading flat; 
    
      cP = get(ax1,'Currentpoint');
      x = cP(1,1);
      y = cP(1,2);
      set(cursor_handle,'Xdata',x,'Ydata',y,'visible','on')
    
      set(gca,'ButtonDownFcn', @mouseclick_callback)
      set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)

  end

  % now attach the function to the axes
  set(gca,'ButtonDownFcn', @mouseclick_callback)

  % and we also have to attach the function to the children, in this
  % case that is the line in the axes.
  set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)

  set(ax1,'ButtonDownFcn', @mouseclick_callback)

end


