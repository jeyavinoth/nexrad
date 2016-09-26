function data = readgpm(gpmFile,swathSelect)

  gpmInfo = h5info(gpmFile); 

  data.lat = h5read(gpmFile,sprintf('/%s/Latitude',swathSelect)); 
  data.lon = h5read(gpmFile,sprintf('/%s/Longitude',swathSelect)); 
  data.airPres = h5read(gpmFile,sprintf('/%s/airPressure',swathSelect)); 
  data.precipRate = h5read(gpmFile,sprintf('/%s/surfPrecipTotRate',swathSelect)); 
  data.precipProf = h5read(gpmFile,sprintf('/%s/precipTotRate',swathSelect)); 
  data.precipLiqFrac = h5read(gpmFile,sprintf('/%s/surfLiqRateFrac',swathSelect)); 

  data.precipType = double(h5read(gpmFile,sprintf('/%s/Input/precipitationType',swathSelect)))./1e7; 

end
