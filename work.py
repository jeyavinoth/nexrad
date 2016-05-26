import matplotlib
# matplotlib.use('TkAgg')

import pyart
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import copy

# global sample file
data = '/media/diskstation/homes/jj/jimmy/nexrad/data/KVNX20110425_092733_V06'


# main function 
def main():
    radar = pyart.io.read_nexrad_archive(data)

    for key in radar.fields.keys():
        print key

    # coh_pwr = copy.deepcopy(radar.fields['differential_phase'])
    # coh_pwr['data'] = coh_pwr['data']*0.+1.
    # radar.fields['normalized_coherent_power'] = coh_pwr

    # print 'normalized coherent power'
    # phidp, kdp = pyart.correct.phase_proc_lp(radar, 0.0, debug=True)
    # radar.add_field('kdp', kdp)

    # refData = radar.fields['reflectivity']
    # kdp = radar.fields['differential_phase']
   
    print 'pyart regridding'

    grid = pyart.map.grid_from_radars((radar,),grid_shape=(1,241,241),grid_limits=((2000, 2000), (-123000.0, 123000.0), (-123000.0, 123000.0)),fields=['reflectivity'])


    # grid = pyart.map.grid_from_radars(radar,(30,400,400), ((0.,15000.),(-200000.,200000.),(-200000.,200000.)), fields=['differential_phase','reflectivity','kdp'], refl_field='reflectivity',roi_func='dist_beam',h_factor=0.,nb=0.5,bsp=1.,min_radius=502)

    # grid = pyart.map.grid_from_radars(radar,(30,400,400), ((0.,15000.),(-200000.,200000.),(-200000.,200000.)), fields=['reflectivity'], refl_field='reflectivity',roi_func='dist_beam',h_factor=0.,nb=0.5,bsp=1.,min_radius=502)

    # kdp = grid.fields['kdp']['data'][0];
    ref = grid.fields['reflectivity']['data'][0];

    # find ref > 40 
    cores = findcores(ref)

    print 'pyart plotting'

    fig = plt.figure()

    ax = fig.add_subplot(221)
    CS = plt.pcolor(ref,cmap=plt.cm.hot,vmin=0,vmax=64)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Reflectivity (dBZ)')

    ax = fig.add_subplot(222)
    CS = plt.pcolor(cores['backAvg'],cmap=plt.cm.hot,vmin=0,vmax=64)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Background Mean')

    ax = fig.add_subplot(223)
    CS = plt.pcolor(cores['ref40'],cmap=plt.cm.cool,vmin=0,vmax=1)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Reflectivity > 40 (dBZ)')

    fig.savefig('./testimg.png')
    plt.close(fig)
    # plt.show()


def findcores(ref): 

    # cores of atleast 40 dbz
    ref40 = (ref > 40) 

    # compute the backbround average for the pixels desired
    backAvg = findbackground(ref)

    # return {'ref40': ref40, 'backAvg': backAvg}
    return {'ref40':ref40,'backAvg':backAvg}

def findbackground(ref): 

    arrSize = ref.shape
    compSize = 20

    meanAvg = np.full((arrSize[0],arrSize[1]),np.nan)

    # for i in np.arange(compSize/2,arrSize[0]-compSize/2): 
    #     for j in np.arange(compSize/2,arrSize[1]-compSize/2): 

    for i in np.arange(0,arrSize[0]): 
        for j in np.arange(0,arrSize[1]): 

            # backAvg = ref[i-compSize/2::i+compSize/2,j-compSize/2::j+compSize/2]
            # print backAvg.shape

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
           
            print backAvg.shape
            meanAvg[i,j] = np.nanmean(backAvg)
    
    return meanAvg

# executing the main function 
if __name__ == "__main__": 
    main()
