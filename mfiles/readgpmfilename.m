function data = readgpm(gpmFile,swathSelect)

  gpmInfo = h5info(gpmFile); 

  data.lat = double(h5read(gpmFile,sprintf('/%s/Latitude',swathSelect))); 
  data.lon = double(h5read(gpmFile,sprintf('/%s/Longitude',swathSelect))); 
  data.airPres = double(h5read(gpmFile,sprintf('/%s/airPressure',swathSelect))); 
  data.precipRate = double(h5read(gpmFile,sprintf('/%s/surfPrecipTotRate',swathSelect))); 
  data.precipProf = double(h5read(gpmFile,sprintf('/%s/precipTotRate',swathSelect))); 
  data.precipLiqFrac = double(h5read(gpmFile,sprintf('/%s/surfLiqRateFrac',swathSelect))); 

  data.precipType = double(h5read(gpmFile,sprintf('/%s/Input/precipitationType',swathSelect)))./1e7; 
  
  data.year = double(h5read(gpmFile,sprintf('/%s/ScanTime/Year',swathSelect))); 
  data.doy = double(h5read(gpmFile,sprintf('/%s/ScanTime/DayOfYear',swathSelect))); 
  data.dom = double(h5read(gpmFile,sprintf('/%s/ScanTime/DayOfMonth',swathSelect))); 
  data.hr = double(h5read(gpmFile,sprintf('/%s/ScanTime/Hour',swathSelect))); 
  data.minute = double(h5read(gpmFile,sprintf('/%s/ScanTime/Minute',swathSelect))); 

  data.time = data.hr + data.minute./60; 

end
