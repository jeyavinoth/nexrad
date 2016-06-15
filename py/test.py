import matplotlib
# matplotlib.use('TkAgg')

import pyart
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import copy

# global sample file
data = '/media/diskstation/homes/jj/jimmy/nexrad/data/KVNX20110425_092733_V06'

# sample plotting function 
def samplePlot(radar): 
    # display the lowest elevation scan data
    display = pyart.graph.RadarDisplay(radar)
    fig = plt.figure(figsize=(9, 12))

    plots = [
            # variable-name in pyart, display-name that we want, sweep-number of radar (0=lowest ref, 1=lowest velocity)
            ['reflectivity', 'Reflectivity (dBZ)', 0],
            ['differential_reflectivity', 'Zdr (dB)', 0],
            ['differential_phase', 'Phi_DP (deg)', 0],
            ['cross_correlation_ratio', 'Rho_HV', 0],
            ['velocity', 'Velocity (m/s)', 1],
            ['spectrum_width', 'Spectrum Width', 1]

            ]

    def plot_radar_images(plots):
        ncols = 2
        nrows = len(plots)/2

        for plotno, plot in enumerate(plots, start=1):
            print plotno, plot
            ax = fig.add_subplot(nrows, ncols, plotno)
            display.plot(plot[0], plot[2], ax=ax, title=plot[1],
            colorbar_label='',
            axislabels=('East-West distance from radar (km)' if plotno == 6 else '', 
            'North-South distance from radar (km)' if plotno == 1 else ''))
            display.set_limits((-300, 300), (-300, 300), ax=ax)
            display.set_aspect_ratio('equal', ax=ax)
            display.plot_range_rings(range(100, 350, 100), lw=0.5, col='black', ax=ax)
        plt.show()


    plot_radar_images(plots)


# main function 
def main():
    radar = pyart.io.read_nexrad_archive(data)

    for key in radar.fields.keys():
        print key

    coh_pwr = copy.deepcopy(radar.fields['differential_phase'])
    coh_pwr['data'] = coh_pwr['data']*0.+1.
    radar.fields['normalized_coherent_power'] = coh_pwr

    print 'normalized coherent power'

    phidp, kdp = pyart.correct.phase_proc_lp(radar, 0.0, debug=True)
    radar.add_field('kdp', kdp)



    # refData = radar.fields['reflectivity']
    # kdp = radar.fields['differential_phase']
   
    # grid = pyart.map.grid_from_radars((radar,),grid_shape=(1,241,241),grid_limits=((2000, 2000), (-123000.0, 123000.0), (-123000.0, 123000.0)),fields=['reflectivity','kdp'])

    grid = pyart.map.grid_from_radars(radar,(30,400,400), ((0.,15000.),(-200000.,200000.),(-200000.,200000.)), fields=['differential_phase','reflectivity','kdp'], refl_field='reflectivity',roi_func='dist_beam',h_factor=0.,nb=0.5,bsp=1.,min_radius=502)

    kdp = grid.fields['kdp']['data'][0];
    ref = grid.fields['reflectivity']['data'][0];

    fig = plt.figure()

    # ax = fig.add_subplot(121)
    # ax.imshow(grid.fields['reflectivity']['data'][0], origin='lower')
    # plt.show()

    # ax = fig.add_subplot(122)
    # ax.imshow(ref, origin='lower')
    # plt.show()

    ax = fig.add_subplot(121)
    CS = plt.pcolor(ref,cmap=plt.cm.hot,vmin=0,vmax=64)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Reflectivity (dBZ)')

    ax = fig.add_subplot(122)
    CS = plt.pcolor(kdp,cmap=plt.cm.hot_r,vmin=0,vmax=6.0)
    cbar = plt.colorbar(CS)
    cbar.ax.set_ylabel('Kdp (deg km-1)')

    fig.savefig('./testimg.png')
    plt.close(fig)
    # plt.show()

    # samplePlot(radar)

# executing the main function 
if __name__ == "__main__": 
    main()
