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
    folder = '/mnt/drive1/jj/nexrad/data/tempData/'
    radarInfo = readData(folder)
    grid = convToGrid(radarInfo['radarData'])
    runfile(grid)

def readData(folder):
    searchString = folder + '*'
    radarFiles = glob.glob(searchString)
    radarData = []
    cnt = 0
    
    firstFile = radarFiles[0]
    folderLen = len(folder)
    time_hh = firstFile[13+folderLen:15+folderLen]
    time_min = firstFile[15+folderLen:17+folderLen]
    time_sec = firstFile[17+folderLen:19+folderLen]

    for filename in radarFiles: 
        radar = pyart.io.read_nexrad_archive(filename)
        radarData.append(radar)
        cnt = cnt + 1
        print ('Completed {0}'.format(filename))

    return {'radarData': radarData, 'hh': time_hh, 'min': time_min, 'sec': '00'}

def convToGrid(radarData):
    grid = pyart.map.grid_from_radars(radarData,grid_shape=(1,1000,1000),grid_limits=((2000, 2000), (-1000000.0, 1000000.0), (-1000000.0, 1000000.0)),fields=['reflectivity'])
    return grid


# reading in one nexrad file and plotting the figures
def runfile(grid):
   
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

    # print 'pyart plotting'

    outMatFile = './outData/test.mat'
    sio.savemat(outMatFile,{'cores_40':cores['ref40'], 'lon':lon,'lat':lat,'ref':ref,'cores_bg':cores['corebg'],'cores':cores['cores']}) 

    fig = plt.figure()

    ax = fig.add_subplot(221)
    CS = plt.pcolor(lon,lat,ref,cmap=plt.cm.hot,vmin=0,vmax=64)
    # ax.imshow(ref,origin='lower'); 
    cbar = plt.colorbar(CS)
    plt.title('Reflectivity (dBZ)')
    ax.tick_params(axis='both',which='major',labelsize=7)
    ax.tick_params(axis='both',which='minor',labelsize=7)

    ax = fig.add_subplot(222)
    CS = plt.pcolor(cores['backAvg'],cmap=plt.cm.hot,vmin=0,vmax=64)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Background Mean (dBZ)')

    ax = fig.add_subplot(222)
    CS = plt.pcolor(lon,lat,cores['ref40'],cmap=plt.cm.cool,vmin=0,vmax=1)
    cbar = plt.colorbar(CS)
    plt.title('Reflectivity > 40 dBz')
    ax.tick_params(axis='both',which='major',labelsize=7)
    ax.tick_params(axis='both',which='minor',labelsize=7)

    ax = fig.add_subplot(223)
    CS = plt.pcolor(lon,lat,cores['corebg'],cmap=plt.cm.cool,vmin=0,vmax=1)
    cbar = plt.colorbar(CS)
    plt.title('Background Comp Core')
    ax.tick_params(axis='both',which='major',labelsize=7)
    ax.tick_params(axis='both',which='minor',labelsize=7)

    ax = fig.add_subplot(224)
    CS = plt.pcolor(lon,lat,cores['cores'],cmap=plt.cm.cool,vmin=0,vmax=1)
    cbar = plt.colorbar(CS)
    plt.title('Final Core Selection')
    ax.tick_params(axis='both',which='major',labelsize=7)
    ax.tick_params(axis='both',which='minor',labelsize=7)

    fig.suptitle("2011-04-25 (09:00)")

    fig.savefig('./images/test.png')
    plt.close(fig)

    # plt.show()


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
