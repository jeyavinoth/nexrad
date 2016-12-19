function data = readgpm(yySelect,mmSelect,ddSelect,hhSelect,swathSelect)

  % reading gpm data from the server /mnt/drive2/gpmdata/
  % example: data = readgpm(2015,06,08,02,'NS')

  % % select date
  % yySelect = 2015; 
  % mmSelect = 07; 
  % ddSelect = 01; 
  % hhSelect = 02; 

  % select width
  % swathSelect = 'NS'; 

  % folder for gpm data
  gpmFolder = '/mnt/drive1/gpmdata/'; 


  % create filename using selected date
  gpmDateFolder = fullfile(gpmFolder,sprintf('%04d',yySelect),sprintf('%02d',mmSelect),sprintf('%02d',ddSelect),'radar');

  % reading all the files in the folder for the day 
  gpmDirList = dir(fullfile(gpmDateFolder,'*.HDF5')); 
  gpmFileList = char({gpmDirList.name}); 

  % Extracting the filename that matches the hour
  gpmStarttime = str2num(gpmFileList(:,35:36)) + str2num(gpmFileList(:,37:38))./60; 
  gpmEndtime = str2num(gpmFileList(:,43:44)) + str2num(gpmFileList(:,45:46))./60;

  % adding 24 hours to the end time if it exceed the day
  ind = find (gpmEndtime < gpmStarttime); 
  gpmEndtime(ind) = gpmEndtime(ind) + 24; 

  % subtracting 24 hours to the start time if it is from the previous day
  ind = find (gpmStarttime > gpmEndtime); 
  gpmStarttime(ind) = gpmStarttime(ind) - 24; 

  % looking for the file that falls within the start time and end time given in the filename
  fileInd = find (hhSelect > gpmStarttime & hhSelect <= gpmEndtime); 

  if (isempty(fileInd))
    error('No file found for the day, within the folder for the specific date.'); 
  end

  % getting the full file path of the file
  selectFile = gpmFileList(fileInd,:); 
  gpmFile = fullfile(gpmDateFolder,selectFile); 

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
