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

# global sample file

# main function to read in all the necessary nexrad data 
def main():
    folder = '/mnt/drive1/jj/nexrad/data/raw_station_data/'

    file1 = 'KVNX20110425_090129_V06';
    # file2 = 'KVNX20110425_090129_V06';
    # file1 = 'KICT20110425_090146_V03'; 
    # file2 = 'KICT20110425_090146_V03'; 
    
    # for filename in os.listdir(folder):
    #     if filename.endswith('_V06'):
    #         imgFile = '/mnt/drive1/jj/nexrad/src/images' + filename + '.png'
    #         if os.path.isfile(imgFile):
    #             print ('skipping' + filename)
    #             continue 
    #         else:
    #             runfile(folder, file1, file2)
    runfile(folder,file1,file2); 
            

# reading in one nexrad file and plotting the figures
def runfile(folder, file1):
    fullfile1 = folder + file1

    print fullfile1
    print fullfile2

    radar1 = pyart.io.read_nexrad_archive(fullfile1)
    radar2 = pyart.io.read_nexrad_archive(fullfile2)
    
    time_hh = file1[13:15]
    time_min = file1[15:17]
    time_sec = file1[17:19]

    # for key in radar.fields.keys():
    #     print key

    # coh_pwr = copy.deepcopy(radar.fields['differential_phase'])
    # coh_pwr['data'] = coh_pwr['data']*0.+1.
    # radar.fields['normalized_coherent_power'] = coh_pwr

    # print 'normalized coherent power'
    # phidp, kdp = pyart.correct.phase_proc_lp(radar, 0.0, debug=True)
    # radar.add_field('kdp', kdp)

    # refData = radar.fields['reflectivity']
    # kdp = radar.fields['differential_phase']
   
    # print 'pyart regridding'

    # grid = pyart.map.grid_from_radars((radar1,radar2,),grid_shape=(1,241,241),grid_limits=((2000, 2000), (-123000.0, 123000.0), (-123000.0, 123000.0)),fields=['reflectivity'])
    grid = pyart.map.grid_from_radars((radar1,radar2,),grid_shape=(1,482,482),grid_limits=((2000, 2000), (-246000.0, 500000.0), (-246000.0, 500000.0)),fields=['reflectivity'])

    axInfo =  grid.axes

    latOrigin = axInfo['lat']['data']
    lonOrigin = axInfo['lon']['data']
    altOrigin = axInfo['alt']['data']

    xArray = axInfo['x_disp']['data']
    yArray = axInfo['y_disp']['data']

    lon,lat = pyart.core.cartesian_to_geographic_aeqd(xArray,yArray,lonOrigin,latOrigin)

    # grid = pyart.map.grid_from_radars(radar,(30,400,400), ((0.,15000.),(-200000.,200000.),(-200000.,200000.)), fields=['differential_phase','reflectivity','kdp'], refl_field='reflectivity',roi_func='dist_beam',h_factor=0.,nb=0.5,bsp=1.,min_radius=502)

    # grid = pyart.map.grid_from_radars(radar,(30,400,400), ((0.,15000.),(-200000.,200000.),(-200000.,200000.)), fields=['reflectivity'], refl_field='reflectivity',roi_func='dist_beam',h_factor=0.,nb=0.5,bsp=1.,min_radius=502)

    # kdp = grid.fields['kdp']['data'][0];
    ref = grid.fields['reflectivity']['data'][0];
    ref = np.asarray(ref)
    ref[ref==0.0] = np.nan

    # find ref > 40 
    cores = findcores(ref)

    # print 'pyart plotting'

    outMatFile = './outData/' + file1 + '_' + file2 + '.mat'
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

    fig.suptitle("2011-04-25 (%s:%s:%s)" % (time_hh,time_min,time_sec))

    fig.savefig('./images/' + file1 + '_' + file2 + '.png')
    plt.close(fig)

    print ('Completed ' + file1 +'_' + file2)
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
