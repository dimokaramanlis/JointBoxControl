# Single Color RGB565 Blob Tracking Example
#
# This example shows off single color RGB565 tracking using the OpenMV Cam.

import sensor, image, time, math
from pyb import Pin
from pid import PID

M1Pin_P0 = Pin(Pin.board.P0, Pin.OUT_PP) # P0
print(M1Pin_P0)
M2Pin_P1 = Pin(Pin.board.P1, Pin.OUT_PP) # P1
mousepins = [M1Pin_P0, M2Pin_P1]


thresholds_body = [ (0, 50)]  # black mouse
thresholds_tail = [ (70, 140)]  # black mouse

sensor.reset()
sensor.set_pixformat(sensor.GRAYSCALE)
sensor.set_framesize(sensor.QVGA)
sensor.skip_frames(time = 500)
sensor.set_transpose(True)
sensor.set_vflip(True)
sensor.set_windowing([94,26,156,192])
#sensor.set_auto_gain(False) # must be turned off for color tracking
#sensor.set_auto_whitebal(False) # must be turned off for color tracking
#sensor.set_auto_exposure(False, exposure_us = 15000)
#sensor.set_auto_gain(False, gain_db = 50)
## 90 DEGREES ROTATION -> https://docs.openmv.io/library/omv.sensor.html

clock = time.clock()
#=================================================================================================
# only change these numbers for defining the box, both sides should be symmetric
myRegion_M1 = [0, 5, 212, 72]
myRegion_M2 = [0, 77, 212, 72]
roiRegion   = [min([myRegion_M1[0], myRegion_M2[0]]), min([myRegion_M1[1], myRegion_M2[1]]),
    max([myRegion_M1[2], myRegion_M2[2]]), myRegion_M1[1]+myRegion_M2[3]]
xscaleM1 = myRegion_M1[2]/ myRegion_M2[2]
yscaleM1 = myRegion_M2[3]/myRegion_M1[3]
myRegion = [myRegion_M1, myRegion_M2]
colmouse = [(0, 0, 0), (100,100,100)]
#=================================================================================================
roiRegion   = [min([myRegion_M1[0], myRegion_M2[0]]), min([myRegion_M1[1], myRegion_M2[1]]),
    max([myRegion_M1[2], myRegion_M2[2]]), myRegion_M1[1]+myRegion_M2[3]]
myRegion = [myRegion_M1, myRegion_M2]
colmouse = [(0, 0, 0), (100,100,100)]

targetAngle = [math.pi/2, -math.pi/2]
#=================================================================================================
loc1 = [109, 64]
loc2 = [109 , 91]
locvec = [loc1, loc2]
Rtrigger = [8, 10] #8 for single mice, 10 for pairs or implanted
thetaRot = math.pi/4.2
#=================================================================================================
# tracking variables
mousecent = [[0, 0], [0, 0]];
mousepts  = [[0, 0, 0, 0], [0, 0, 0, 0]];
mousehdir = [[0, 0], [0, 0]];
maxspeed  = [2, 2]
mouseeli  = [[0, 0], [0, 0]]
n         = [0, 0]
#=================================================================================================
while(True):
    clock.tick()
    img = sensor.snapshot()
    img.median(2)
    zeroedge    = [(0,0),(0,0),(0,0),(0,0)]
    mcorners    = [zeroedge, zeroedge];
    mouseinzone = [False, False]
    ismouseblob = [False, False]
    #============================================================================
    # operations
    for imouse in range(0,2):
        mouseblob = img.find_blobs(thresholds_body, pixels_threshold=80,
                                   merge = True,area_threshold=80, roi =myRegion[imouse])
        if len(mouseblob)>0:
            mouseblob = mouseblob[0]
            mx        = mouseblob.cxf()
            my        = mouseblob.cyf()
            theta     = mouseblob.rotation()
            mouseaxis = mouseblob.major_axis_line()
            #-------------------------------------------------------------
            if mouseblob.elongation()<0.95 and mouseblob.pixels()<800 and mouseblob.area()<800:
                ismouseblob[imouse] = True
                n[imouse]+=1
                #----------------------------------------------------------------------------------
                vx = mx - mousecent[imouse][0]
                vy = my - mousecent[imouse][1]
                whist = 0.9 * math.exp(-0.1*mouseblob.elongation())
                #whist = 0.9 * (1  - math.exp(-n[imouse]/50)) * math.exp(-0.1*mouseblob.elongation())
                vxest = (1-whist) * vx + whist * mousehdir[imouse][0]
                vyest = (1-whist) * vy + whist * mousehdir[imouse][1]
                hx = mouseaxis[2] - mouseaxis[0]
                hy = mouseaxis[3] - mouseaxis[1]
                if hx*vxest + hy*vyest < 0:
                    hx = -hx
                    hy = -hy

                hnorm = math.sqrt(hx**2 + hy**2)
                vnorm = math.sqrt(vxest**2 + vyest**2)
                vxest = 0.2*hx/hnorm + 0.8*vxest/vnorm
                vyest = 0.2*hy/hnorm + 0.8*vyest/vnorm
                headdir = math.atan2(hy, hx)
                mousehdir[imouse] = [vxest, vyest]
                mouseeli[imouse]  = [hx, hy]
                mousecent[imouse] = [mx, my]
                mcorners[imouse]  = mouseblob.min_corners()
                print("Mouse ", imouse+1, " X: ", mx, "Y: ", my, " Direction: ", math.degrees(headdir))
                #----------------------------------------------------------------------------------
                thetadiff = targetAngle[imouse]-headdir
                angle = math.pi - math.fabs(math.fabs(thetadiff) - math.pi);
                thetacorrect = math.fabs(thetadiff) < thetaRot

                mdist = math.sqrt((mx - locvec[imouse][0])**2 + (my - locvec[imouse][1])**2)
                distcorr = mdist < Rtrigger[imouse]
                if thetacorrect and distcorr:
                    mouseinzone[imouse] = True
                    mousepins[imouse].value(True)
                    print("Mouse ", imouse+1," detected")
                else:
                    mousepins[imouse].value(False)
    #============================================================================
    # drawing
    for imouse in range(0,2):
        img.draw_rectangle(myRegion[imouse], colmouse[imouse], 1, False)
        img.draw_circle(locvec[imouse][0], locvec[imouse][1], Rtrigger[imouse], colmouse[imouse])
        img.draw_cross(locvec[imouse][0], locvec[imouse][1], colmouse[imouse], size=1, thickness=1)
        if ismouseblob[imouse]:
            img.draw_edges(mcorners[imouse], color = (180,180,180))

            x0 = int(mousecent[imouse][0])
            y0 = int(mousecent[imouse][1])
            plotdir = math.atan2(mouseeli[imouse][1], mouseeli[imouse][0])
            x1 = int(x0 +  20*math.cos(plotdir))
            y1 = int(y0 +  20*math.sin(plotdir))
            img.draw_arrow(x0, y0, x1, y1, color = (180,180,180), thickness=1)

        if mouseinzone[imouse]:
           img.draw_arrow(x0, y0, x1, y1, color = (250,250,250), thickness=1)
           img.draw_edges(mcorners[imouse], color = (250,250,250))
    #============================================================================
