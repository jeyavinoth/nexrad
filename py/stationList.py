import numpy as np 
import scipy.io as sio
import csv
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm

class isd: 
    def __init__(self):
        # self.file = 'isd-history.txt'
        self.file = 'nexrad-stations.txt'
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
                if (cnt <= 2):
                    continue

                # extract station code, lat and lon from the line of information for each station
                
                stationName = line[9:13]
                latString = line[106:116]
                lonString = line[116:126]

                # stationName = line[51:55]
                # latString = line[57:64]
                # lonString = line[65:73]
                
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
        sListCode = [item['sCode'] for item in self.stationList if (item['lat'] > latMin and item['lat'] < latMax and item['lon'] > lonMin and item['lon'] < lonMax and item['sCode'][0] == 'K')]
        sList = [item for item in self.stationList if (item['lat'] > latMin and item['lat'] < latMax and item['lon'] > lonMin and item['lon'] < lonMax and item['sCode'][0] == 'K')]

        # return only the unique values
        return {'stationNames': set(sListCode), 'listInfo':sList}

def main():

    # rangeSelect = [37, 44, -74, -70]
    # latMin = 38
    # latMax = 44
    # lonMin = -88
    # lonMax = -82

    # storm on 06/08/2015
    selectDate = '06_08_2015'; 
    rangeSelect = [33,41,-89,-79]

    # # storm on 08/11/2015
    # selectDate = '08_11_2015'; 
    # rangeSelect = [36,46,-77,-64]

    # #09/19/2015
    # selectDate = '09_19_2015'; 
    # rangeSelect = [39,44,-90,-83]

    # #09/30/2015
    # selectDate = '09_30_2015'; 
    # rangeSelect = [35,49,-81,-60]

    # #10/28/2015
    # selectDate = '10_28_2015'; 
    # rangeSelect = [35,43,-88,-80]

    # #11/18/2015
    # selectDate = '11_18_2015'; 
    # rangeSelect = [32,41,-88,-83]

    latMin = rangeSelect[0]
    latMax = rangeSelect[1]
    lonMin = rangeSelect[2]
    lonMax = rangeSelect[3]


    sList = isd()

    x = sList.searchStationList(latMin, latMax, lonMin, lonMax)
    stationNames = x['stationNames']

    sListInfo = x['listInfo']

    if (not stationNames):
        print "No Stations Found"

    # print sListInfo 

    # create figure and axes instances
    fig = plt.figure(figsize=(8,8))
    ax = fig.add_axes([0.1,0.1,0.8,0.8])
    # create polar stereographic Basemap instance.

    # m = Basemap(projection='stere',lon_0=lon_0,lat_0=90.,lat_ts=lat_0,\
    #                     llcrnrlat=latcorners[0],urcrnrlat=latcorners[2],\
    #                     llcrnrlon=loncorners[0],urcrnrlon=loncorners[2],\
    #                     rsphere=6371200.,resolution='l',area_thresh=10000)

    m = Basemap(width=12000000,height=9000000,projection='lcc',
                        resolution='c',lat_0=50,lon_0=-107.,llcrnrlat=28.,urcrnrlat=46.,llcrnrlon=-93.,urcrnrlon=-66.)
    # draw coastlines, state and country boundaries, edge of map.
    m.drawcoastlines(linewidth=0.25)
    # m.drawstates(linewidth=0.25)
    # m.drawcountries(linewidth=0.25)
    # draw parallels.
    parallels = np.arange(0.,90,10.)
    m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
    # draw meridians
    meridians = np.arange(180.,360.,10.)
    m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)

    lons = []
    lats = []
    codes = []
    for station in sListInfo: 
        lons.append(station['lon'])
        lats.append(station['lat'])
        codes.append(station['sCode'])
        # print "%f - %f" % (station['lon'],station['lat'])

    # lons = np.array(lons)
    # lats = np.array(lats)

    x,y = m(lons,lats)
    print stationNames
    m.plot(x,y,'ro',markersize=5)

    for label, xpt, ypt in zip(codes, x, y):
            plt.text(xpt, ypt, label)

    # fig.savefig('img_08_11_2015.png')
    # fig.savefig('img_09_19_2015.png')
    fig.savefig('img_%s.png' % selectDate)
    # plt.show() 

if __name__ == "__main__":
    main()
