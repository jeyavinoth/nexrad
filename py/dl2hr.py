from xml.dom import minidom
from sys import stdin
from urllib import urlopen,URLopener
from subprocess import call
import os
import numpy as np

def getText(nodelist):
    rc = []
    for node in nodelist:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

def dlStationData(date,timeStep,siteList):

    timeRange = 60 

    dateDirectory = '/mnt/drive4/nexrad/' + date[0:4] + date[5:7] + date[8:10]

    for site in siteList: 

        bucketURL = "http://noaa-nexrad-level2.s3.amazonaws.com"
        dirListURL = bucketURL+ "/?prefix=" + date + "/" + site

        print "listing files from %s" % dirListURL

        #xmldoc = minidom.parse(stdin)
        xmldoc = minidom.parse(urlopen(dirListURL))
        itemlist = xmldoc.getElementsByTagName('Key')
        print len(itemlist) , "keys found..."

        if not os.path.exists(dateDirectory):
            os.makedirs(dateDirectory)

        directory = dateDirectory + "/" + site
        if not os.path.exists(directory):
            os.makedirs(directory)

        # For this test, WCT is downloaded and unzipped directly in the working directory
        # The output files are going in 'output'
        # http://www.ncdc.noaa.gov/wct/install.php
        for x in itemlist:
                file = getText(x.childNodes)

                if (file[-3:] == 'tar'):
                    continue

                if (file[-3:] != '.gz'): 
                    continue

                timeFile = float(file[-13:-11]) + float(file[-11:-9])/60.

                if (timeFile < timeStep-timeRange/60.) or (timeFile > timeStep+timeRange/60.):
                    continue; 

                save_loc = os.path.abspath("%s/%s/%s" % (dateDirectory,site,file[16:]))
                dlLink = "%s/%s" % (bucketURL,file)

                if os.path.exists(save_loc[:-3]):
                    continue

                tempfile = URLopener()
                tempfile.retrieve(dlLink,save_loc)
                
                command2run = 'gunzip ' + save_loc

                call(command2run,shell=True)

                print "%s" % (file)


# all stations that cover east coast of united states
siteList = ['KILX', 'KJKL', 'KLOT', 'KVWX', 'KJGX', 'KMRX', 'KHTX', 'KDIX', 'KILN', 'KJAX', 'KHPX', 'KFFC', 'KOKX', 'KIND', 'KDGX', 'KMOB', 'KLWX', 'KDTX', 'KBOX', 'KBMX', 'KMKX', 'KEVX', 'KGWX', 'KCAE', 'KEOX', 'KLIX', 'KGSP', 'KPAH', 'KDOX', 'KBGM', 'KBUF', 'KIWX', 'KAKQ', 'KTYX', 'KOHX', 'KGYX', 'KMLB', 'KCLX', 'KRLX', 'KLTX', 'KMXX', 'KNQA', 'KPBZ', 'KLVX', 'KVAX', 'KTLH', 'KGRR', 'KMHX', 'KRAX', 'KENX', 'KCCX', 'KFCX', 'KCLE']; 
date = "2015/05/16"; 
# dlStationData(date,timeStep,siteList)

selectCaseFile = '/mnt/drive1/jj/nexrad/src/mfiles/autoSelect.txt'

f = open(selectCaseFile,'r')
lineCnt = 0
for line in f:
    val = line.split()
    date =  '%s/%s/%s'%(val[0],val[1],val[2])
    
    lineCnt = lineCnt + 1 

    if (lineCnt != 61): 
        continue; 

    print date

    # startHr = int(val[6])/100
    # endHr = int(val[7])/100
    # startTime = float(startHr) + float(int(val[6]) - startHr*100)/60
    # endTime = float(endHr) + float(int(val[7]) - endHr*100)/60

    # print line
    # startTime = float(val[8])

    # if (endTime < startTime and startTime > 15):
    #     endTime = endTime + 24; 
    # if (endTime < startTime and startTime < 15):
    #     startTime = startTime - 24; 
    # timeStepList = np.arange(np.ceil(startTime),np.ceil(endTime))

    print line

    startTime = float(val[14])
    endTime = float(val[15])

    startHr = float(int(startTime/100))
    startMin = float(startTime - startHr*100)
    startTime = startHr + startMin/60

    endHr = float(int(endTime/100))
    endMin = float(endTime - endHr*100)
    endTime = endHr + endMin/60

    if (startTime > endTime):
        continue; 

    timeStep = (startTime + endTime) / 2

    dlStationData(date,timeStep,siteList)

f.close()
