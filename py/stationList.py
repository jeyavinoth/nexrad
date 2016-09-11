import numpy as np 
import scipy.io as sio
import csv

class isd: 
    def __init__(self):
        self.file = 'isd-history.txt'
        self.readStationList()
    
    def readStationList(self):

        # initiate the stationList as empty
        self.stationList = []

        # open isd-history.txt file to read in all the station information
        with open(self.file,'rb') as stationFile:

            # read in the data
            reader = csv.reader(stationFile,delimiter='\t')

            # keep count of header information
            cnt = 0
            for line in stationFile:
                cnt = cnt + 1

                # get rid of header information
                if (cnt <= 38):
                    continue
                
                # extract station code, lat and lon from the line of information for each station
                stationName = line[51:55]
                latString = line[57:64]
                lonString = line[65:73]
                
                # if lat or lon or station name is empty then skip the line
                if (stationName.isspace() | latString.isspace() | lonString.isspace()):
                    continue
                
                # convert lat and lon to float values 
                lat = float(latString)
                lon = float(lonString)

                # create a temporary dict to append to the list of station info
                tempDict  = {'sCode': stationName, 'lat': lat, 'lon': lon} 
                
                # append to the list of station data
                self.stationList.append(tempDict)

    # search the stations that fall in to a bounding box
    def searchStationList(self,latMin,latMax,lonMin,lonMax):

        # bounding box criteria
        self.latMin = latMin
        self.latMax = latMax
        self.lonMin = lonMin
        self.lonMax = lonMax
        
        # get the list of stations that fall into the criteria and only US stations, starting with K 
        sList = [item['sCode'] for item in self.stationList if (item['lat'] > latMin and item['lat'] < latMax and item['lon'] > lonMin and item['lon'] < lonMax and item['sCode'][0] == 'K')]

        # return only the unique values
        return set(sList)

def main(): 
    latMin = 38
    latMax = 44
    lonMin = -88
    lonMax = -82

    sList = isd()

    x = sList.searchStationList(latMin, latMax, lonMin, lonMax)

    if (not x):
        print "No Stations Found"

    print x


if __name__ == "__main__":
    main()
