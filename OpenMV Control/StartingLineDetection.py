# StartingLinesDetection - By: BeatrizApgaua - Wed Nov 19 2025

import sensor, time, math
import openmv_funsStartingLine
from pyb import Pin
#=================================================================================================
# set configuration and pins
config_filename = "configStartingLine.txt"
final_config = openmv_funsStartingLine.read_config_file(config_filename)
M1Pin_P0 = Pin(Pin.board.P0, Pin.OUT_PP) # P0
M2Pin_P1 = Pin(Pin.board.P1, Pin.OUT_PP) # PVVCDD1
mousepins = [M1Pin_P0, M2Pin_P1]
mousepins[0].value(False)
mousepins[1].value(False)

## Start Beatriz Added 123
#Blue side
M1BluePin_P3 = Pin(Pin.board.P2, Pin.OUT_PP) #
M2BluePin_P4 = Pin(Pin.board.P4, Pin.OUT_PP) #

#Red side
M1RedPin_P5 = Pin(Pin.board.P5, Pin.OUT_PP) #
M2RedPin_P6 = Pin(Pin.board.P6, Pin.OUT_PP) #

StartLinepins = [[M1BluePin_P3, M2BluePin_P4],
    [M1RedPin_P5, M2RedPin_P6]]

for side in range(2):
    for imouse in range(2):
        StartLinepins[side][imouse].value(False)

## End Beatriz Added

print("Final Configuration:")
print(final_config)
print("Mousepins:")
print(mousepins)
print("StartLinepins:")
print(StartLinepins)
#=================================================================================================
# setup sensor
sensor.reset()
sensor.set_pixformat(sensor.GRAYSCALE)
sensor.set_framesize(sensor.QVGA)
if final_config['transpose_first']:
    sensor.set_transpose(final_config['to_transpose'])
    sensor.set_hmirror(final_config['to_hmirror'])
    sensor.set_vflip(final_config['to_vflip'])
else:
    sensor.set_hmirror(final_config['to_hmirror'])
    sensor.set_vflip(final_config['to_vflip'])
    sensor.set_transpose(final_config['to_transpose'])
sensor.set_windowing(final_config['sensor_window'])
sensor.set_brightness(final_config['sensor_brightness'])
clock = time.clock()
#=================================================================================================
# set params from text config
bodyThresh  = [final_config['mouse_thres_int'], final_config['mouse_thres_int']]
targetAngle = [math.pi/2, -math.pi/2]
myRegion    = [final_config['region_M1'], final_config['region_M2']] # This is the region of the whole screen
colmouse    = [final_config['draw_M1'], final_config['draw_M2']]
locvec      = [final_config['platform_cent_M1'], final_config['platform_cent_M2']]
Rtrigger    = final_config['radius_M1_M2'] #8 for single, 10 for pairs
thetaRot    = [math.radians(final_config['angle_requirement_deg']),
               math.radians(final_config['angle_requirement_deg'])] # keep at 45
hisx        = final_config['history_alpha_x']
hisy        = final_config['history_alpha_y']
#=================================================================================================
## Start Beatriz Added
if final_config['StartingLine'] == 1:
    size_StartLine = final_config['size_StartLine']  # (w, h)
    start_w = size_StartLine[0]
    start_h = size_StartLine[1]

    # Centers for each mouse
    M1_BlueStartLine = [0, 0]
    M1_RedStartLine  = [0, 0]
    M2_BlueStartLine = [0, 0]
    M2_RedStartLine  = [0, 0]

    i = 0
    M1_BlueStartLine[i] = final_config['platform_cent_M1'][i] - final_config['dist_StartLine'][i] - final_config['size_StartLine'][i]
    M1_RedStartLine[i] = final_config['platform_cent_M1'][i] + final_config['dist_StartLine'][i]
    M2_BlueStartLine[i] = final_config['platform_cent_M2'][i] - final_config['dist_StartLine'][i] - final_config['size_StartLine'][i]
    M2_RedStartLine[i] = final_config['platform_cent_M2'][i] + final_config['dist_StartLine'][i]

    i = 1
    M1_BlueStartLine[i] = final_config['platform_cent_M1'][i] + final_config['dist_StartLine'][i] - final_config['size_StartLine'][i]
    M1_RedStartLine[i] = final_config['platform_cent_M1'][i] + final_config['dist_StartLine'][i] - final_config['size_StartLine'][i]
    M2_BlueStartLine[i] = final_config['platform_cent_M2'][i] - final_config['dist_StartLine'][i]
    M2_RedStartLine[i] = final_config['platform_cent_M2'][i] - final_config['dist_StartLine'][i]


    BlueStartLine = [M1_BlueStartLine, M2_BlueStartLine]
    RedStartLine  = [M1_RedStartLine, M2_RedStartLine]

    def center_to_roi(c):
        cx, cy = c
        x = int(cx - start_w // 2)
        y = int(cy - start_h // 2)
        return (x, y, int(start_w), int(start_h))

    # Per-mouse ROIs: [ [blue_roi, red_roi], [blue_roi, red_roi] ]
    start_rois = []
    for i in range(2):
        start_rois.append([center_to_roi(BlueStartLine[i]),
                           center_to_roi(RedStartLine[i])])
else:
    # Dummy values so code doesn't crash if StartingLine == 0
    size_StartLine = (0, 0)
    BlueStartLine = [(0, 0), (0, 0)]
    RedStartLine  = [(0, 0), (0, 0)]
    start_rois = [[(0, 0, 0, 0), (0, 0, 0, 0)],
                  [(0, 0, 0, 0), (0, 0, 0, 0)]]


## End Beatriz Added

#=================================================================================================
# tracking variables
mousecent = [[0, 0], [0, 0]];
mousepts  = [[0, 0, 0, 0], [0, 0, 0, 0]];
mousehdir = [[0, 0], [0, 0]];
maxspeed  = [2, 2]
mouseeli  = [[0, 0], [0, 0]]
n         = [0, 0]
prevcorr  = [False, False]
in_blue = [False, False]    #BA
in_red  = [False, False]    #BA
while(True):
    clock.tick()
    if final_config['median_blur']:
        img = sensor.snapshot().median(3)
    else:
        img = sensor.snapshot()
    zeroedge    = [(0,0),(0,0),(0,0),(0,0)]
    mcorners    = [zeroedge, zeroedge];
    mouseinzone = [False, False]
    ismouseblob = [False, False]

    #in_blue = [False, False]    #BA
    #in_red  = [False, False]    #BA

    for imouse in range(0,2):
        mousepins[imouse].value(False)

        if final_config['StartingLine'] == 1:
            StartLinepins[0][imouse].value(False)   # Blue
            StartLinepins[1][imouse].value(False)   # Red

        mouseblob = img.find_blobs([bodyThresh[imouse]], merge = True,
        pixels_threshold=75, area_threshold=75, roi =myRegion[imouse])
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
                # this tracks mouse position and axis and compare to previous frames to obtaina  direction axis
                vx = mx - mousecent[imouse][0]
                vy = my - mousecent[imouse][1]
                # history dependence adapts on mouse detection and shape
                elfacv  = 0.8 + 0.2 * math.exp(-0.001*mouseblob.pixels())
                elfac   = 0.5 + 0.5 * math.exp(-0.001*mouseblob.pixels())
                #whist = hpcnt * (1  - math.exp(-n[imouse]/50)) * math.exp(-0.1*mouseblob.elongation())
                vxest = (1-elfacv*hisx) * vx + elfacv*hisx * mousehdir[imouse][0]
                vyest = (1-elfacv*hisy) * vy + elfacv*hisy * mousehdir[imouse][1]
                hx = mouseaxis[2] - mouseaxis[0]
                hy = mouseaxis[3] - mouseaxis[1]
                if hx*vxest + hy*vyest < 0:
                    hx = -hx
                    hy = -hy

                hnorm = math.sqrt(hx**2 + hy**2)
                vnorm = math.sqrt(vxest**2 + vyest**2)
                vxest = (1 - elfac*hisx)*hx/hnorm + elfac*hisx*vxest/vnorm
                vyest = (1 - elfac*hisy)*hy/hnorm + elfac*hisy*vyest/vnorm
                headdir = math.atan2(hy, hx)
                mousehdir[imouse] = [vxest, vyest]
                mouseeli[imouse]  = [hx, hy]
                mousecent[imouse] = [mx, my]
                mcorners[imouse]  = mouseblob.min_corners()
                print("Mouse ", imouse+1, " X: ", mx, "Y: ", my, " Direction: ", math.degrees(headdir))
                #----------------------------------------------------------------------------------
                thetadiff = targetAngle[imouse]-headdir
                angle = math.pi - math.fabs(math.fabs(thetadiff) - math.pi);
                thetacorrect = math.fabs(thetadiff) < thetaRot[imouse] #  If the current direction is within tolerance → thetacorrect = True.
                mdist = math.sqrt((mx - locvec[imouse][0])**2 + (my - locvec[imouse][1])**2)
                distcorr = mdist < Rtrigger[imouse]

                # this is used for debug mode
                if final_config['debug']:
                    thetacorrect = True

                if thetacorrect and distcorr and abs(vxest):
                    #print(abs(vxest))
                    mouseinzone[imouse] = True
                    mousepins[imouse].value(True)
                    prevcorr[imouse] = True
                    print("Mouse ", imouse+1," detected")
                else:
                    mousepins[imouse].value(False)
                    prevcorr[imouse] = False

                #----------------------------------------------------------------------------------
                ## Start Beatriz Added
                # for checking the start lines

                #mice corners
                x1_corner=mcorners[imouse][0][0] #[mouse], [corner], [x-y]
                x2_corner=mcorners[imouse][1][0] #x1
                y1_corner=mcorners[imouse][0][1] #x1
                y3_corner=mcorners[imouse][2][1] #x1


                Blue_rec = [BlueStartLine[imouse][0],
                    BlueStartLine[imouse][1],
                    size_StartLine[0],
                    size_StartLine[1]]
                Red_rec = [RedStartLine[imouse][0],
                    RedStartLine[imouse][1],
                    size_StartLine[0],
                    size_StartLine[1]]

                if final_config['StartingLine'] == 1:

                    in_blue[imouse] = False
                    in_red[imouse] = False
                    for x in range(x1_corner, x2_corner + 1):
                        for y in range(y1_corner, y3_corner + 1):
                            # BLUE side
                            bx, by, bw, bh = Blue_rec #start_rois[imouse][0]
                            if bx <= x <= bx + bw and by <= y <= by + bh:
                                in_blue[imouse] = True
                                StartLinepins[0][imouse].value(True)

                            # RED side
                            rx, ry, rw, rh = Red_rec #start_rois[imouse][1]
                            if (rx <= x <= rx + rw) and (ry <= y <= ry + rh):
                                in_red[imouse] = True
                                StartLinepins[1][imouse].value(True)

                ## End Beatriz Added
        else:
            n[imouse] = 0
            prevcorr[imouse] = False

    #============================================================================
    # drawing
    for imouse in range(0,2):
        img.draw_rectangle(myRegion[imouse], colmouse[imouse], 1, False)
        img.draw_circle(locvec[imouse][0], locvec[imouse][1], Rtrigger[imouse], colmouse[imouse]),
        img.draw_cross(locvec[imouse][0], locvec[imouse][1], colmouse[imouse], size=1, thickness=1)

        if ismouseblob[imouse]:
            img.draw_edges(mcorners[imouse], color = (180,180,180))

            x0 = int(mousecent[imouse][0])
            y0 = int(mousecent[imouse][1])
            plotdir = math.atan2(mouseeli[imouse][1], mouseeli[imouse][0])
            x1 = int(x0 +  20*math.cos(plotdir))
            y1 = int(y0 +  20*math.sin(plotdir))
            img.draw_arrow(x0, y0, x1, y1, color = (180,180,180), thickness=1)

            if in_blue[imouse]:
                img.draw_arrow(x0, y0, x1, y1, color = (250,250,250), thickness=1)
                img.draw_edges(mcorners[imouse], color = (250,250,250))
            if in_red[imouse]:
                img.draw_arrow(x0, y0, x1, y1, color = (250,250,250), thickness=1)
                img.draw_edges(mcorners[imouse], color = (250,250,250))

        if mouseinzone[imouse]:
           img.draw_arrow(x0, y0, x1, y1, color = (250,250,250), thickness=1)
           img.draw_edges(mcorners[imouse], color = (250,250,250))

    ## Start Beatriz Added
        if final_config['StartingLine'] == 1:
            Blue_rec = [BlueStartLine[imouse][0],
                BlueStartLine[imouse][1],
                size_StartLine[0],
                size_StartLine[1]]
            Red_rec = [RedStartLine[imouse][0],
                RedStartLine[imouse][1],
                size_StartLine[0],
                size_StartLine[1]]

            img.draw_rectangle(Blue_rec, colmouse[imouse], 1, False)
            img.draw_rectangle(Red_rec,  colmouse[imouse], 1, False)
        ## End Beatriz Added

