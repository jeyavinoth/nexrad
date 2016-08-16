import matplotlib
# matplotlib.use('TkAgg')

import pyart
import numpy as np
import scipy as sp
import scipy.io as sio
import matplotlib.pyplot as plt
import copy
import math
import os
import glob

# global sample file

# main function to read in all the necessary nexrad data 
def main():
    folder = '/mnt/drive4/nexrad/20110425/'
    stationList = ['KAMA','KDDC','KEAX','KFDR','KGLD','KICT','KINX','KSGF','KSRX','KTLX','KTWX','KUEX','KVNX'];

    timeStepList = range(1,25)
    # timeStepList = range(9,10)

    for timeStep in timeStepList:
        radarInfo = readData(folder,timeStep,stationList)
        grid = convToGrid(radarInfo['radarData'])
        runfile(grid,'20110425',timeStep)
        print 'Completed {0}'.format(timeStep)
    
def readData(folder,hr,stationList):

    fileList = []
    folderLen = len(folder)
    
    # for each station in hte provided station list run the code
    for station in stationList:

        # look for all stations given for the date
        searchString = folder + station + '20110425*_V*'
        radarFiles = glob.glob(searchString)
    
        # if no data is found for the station then skip 
        if (len(radarFiles) == 0):
            continue 

        # compute the minimum time difference file and save it to the list
        minDiff = float('Inf') 
        minFile = '' 
        for filename in radarFiles:
            time_hh = filename[13+folderLen:15+folderLen]
            time_min = filename[15+folderLen:17+folderLen]
            time_sec = filename[17+folderLen:19+folderLen]
            time_hhmin = float(time_hh) + float(time_min)/60. + float(time_sec)/3600.
            time_diff = abs(hr - time_hhmin)
            if (time_diff < minDiff and time_diff < float(5./60.)):
                minDiff = time_diff
                minFile = filename
            # print '{0} // {3} --> {1} --> {2}'.format(filename, time_hhmin, time_diff, float(5./60.))

        if (len(minFile) != 0):
            fileList.append(minFile)

    # looping through the selected files that are close to the given hour and reading the necessary data for those files and creating a list of radar data
    radarData = []
    cnt = 0
    for filename in fileList: 
        radar = pyart.io.read_nexrad_archive(filename)
        radarData.append(radar)
        cnt = cnt + 1
        print ('Completed {0}'.format(filename))

    return {'radarData': radarData, 'hh': str(hr), 'min': '00', 'sec': '00'}

def convToGrid(radarData):
    grid = pyart.map.grid_from_radars(radarData,grid_shape=(1,1000,1000),grid_limits=((2000, 2000), (-1000000.0, 1000000.0), (-1000000.0, 1000000.0)),fields=['reflectivity'])
    return grid


# reading in one nexrad file and plotting the figures
def runfile(grid,date,timeStep):
   
    axInfo =  grid.axes

    latOrigin = axInfo['lat']['data']
    lonOrigin = axInfo['lon']['data']
    altOrigin = axInfo['alt']['data']

    xArray = axInfo['x_disp']['data']
    yArray = axInfo['y_disp']['data']

    lon,lat = pyart.core.cartesian_to_geographic_aeqd(xArray,yArray,lonOrigin,latOrigin)

    ref = grid.fields['reflectivity']['data'][0];
    ref = np.asarray(ref)
    ref[ref==0.0] = np.nan

    # find ref > 40 
    cores = findcores(ref)

    outMatFile = './outData/nex_{0}_{1}.mat'.format(date,timeStep)
    sio.savemat(outMatFile,{'cores_40':cores['ref40'], 'lon':lon,'lat':lat,'ref':ref,'cores_bg':cores['corebg'],'cores':cores['cores']}) 


def findcores(ref): 

    # cores of atleast 40 dbz
    ref40 = (ref > 40) 
    
    arrSize = ref40.shape
    
    # compute the backbround average for the pixels desired
    backAvg = findbackground(ref)

    core = np.full((arrSize[0],arrSize[1]),0)

    # all cores including the condition 2
    for i in np.arange(0,arrSize[0]): 
        for j in np.arange(0,arrSize[1]): 

            if (not(ref[i,j] > 0.0 and ref[i,j] < 64.0)):
                core[i,j] = 0 
                continue

            if (ref40[i,j] == True):
                core[i,j] = 1 
                continue 

            diffRef = ref[i,j] - backAvg[i,j]

            if (backAvg[i,j] < 0.0): 
                if (diffRef > 10.0):
                    core[i,j] = 1
            elif (backAvg[i,j] < 42.43):
                if (diffRef > (10.0 - (math.pow(backAvg[i,j],2)/180.0))):
                    core[i,j] = 1
            else:
                if (diffRef > 0.0): 
                    core[i,j] = 1

    corebg = core

    for i in np.arange(0,arrSize[0]): 
        for j in np.arange(0,arrSize[1]): 

            # if (core[i,j] == 0 or np.isnan(core[i,j])):
            if (core[i,j] == 0):
                continue 

            if (backAvg[i,j] < 25):
                radiusSize = 1 #1km
            elif (backAvg[i,j] <30): 
                radiusSize = 2  #2km
            elif (backAvg[i,j] <35): 
                radiusSize = 3 #3km
            elif (backAvg[i,j] <40): 
                radiusSize = 4 #4km
            else:
                radiusSize = 5 #5km

            if (i-radiusSize < 0):
                if (j-radiusSize < 0): 
                    core[0:i+radiusSize,0:j+radiusSize] = 1
                elif (j+radiusSize > arrSize[1]):
                    core[0:i+radiusSize,j-radiusSize:arrSize[1]] = 1
                else:
                    core[0:i+radiusSize,j-radiusSize:j+radiusSize] = 1
            elif (i+radiusSize > arrSize[0]):
                if (j-radiusSize < 0): 
                    core[i-radiusSize:arrSize[0],0:j+radiusSize] = 1
                elif (j+radiusSize > arrSize[1]):
                    core[i-radiusSize:arrSize[1],j-radiusSize:arrSize[1]] = 1
                else:
                    core[i-radiusSize:arrSize[1],j-radiusSize:j+radiusSize] = 1
            else:
                if (j-radiusSize < 0): 
                    core[i-radiusSize:i+radiusSize,0:j+radiusSize] = 1
                elif (j+radiusSize > arrSize[1]):
                    core[i-radiusSize:i+radiusSize,j-radiusSize:arrSize[1]] = 1
                else:
                    core[i-radiusSize:i+radiusSize,j-radiusSize:j+radiusSize] = 1

    # return {'ref40': ref40, 'backAvg': backAvg}
    return {'ref40':ref40, 'backAvg':backAvg, 'cores':core, 'corebg': corebg}

def findbackground(ref): 

    arrSize = ref.shape
    # print arrSize

    compSize = 20

    meanAvg = np.full((arrSize[0],arrSize[1]),np.nan)

    for i in np.arange(0,arrSize[0]): 
        for j in np.arange(0,arrSize[1]): 

            if (i < compSize/2):
                if (j > arrSize[1]-compSize/2):
                    backAvg = ref[0:compSize,arrSize[1]-compSize:arrSize[1]]
                else: 
                    if (j < compSize/2): 
                        backAvg = ref[0:compSize,0:compSize]
                    else: 
                        backAvg = ref[0:compSize,j-compSize/2:j+compSize/2]
            else: 
                if (i > arrSize[0]-compSize/2):
                    if (j < compSize/2):
                        backAvg = ref[arrSize[0]-compSize:arrSize[0],0:compSize]
                    else:
                        backAvg = ref[arrSize[0]-compSize:arrSize[0],j-compSize/2:j+compSize/2]
                else: 
                    if (j < compSize/2): 
                        backAvg = ref[i-compSize/2:i+compSize/2,0:compSize]
                    else: 
                        backAvg = ref[i-compSize/2:i+compSize/2,j-compSize/2:j+compSize/2]
           
            meanAvg[i,j] = np.nanmean(backAvg)
    
    return meanAvg

# executing the main function 
if __name__ == "__main__": 
    main()
