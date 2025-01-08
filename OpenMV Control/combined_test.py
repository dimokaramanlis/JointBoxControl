import sensor, time, math
import openmv_funs
from pyb import Pin
#=================================================================================================
# set configuration and pins
config_filename = "config.txt"
final_config = openmv_funs.read_config_file(config_filename)
M1Pin_P0 = Pin(Pin.board.P0, Pin.OUT_PP) # P0
M2Pin_P1 = Pin(Pin.board.P2, Pin.OUT_PP) # P1
mousepins = [M1Pin_P0, M2Pin_P1]

print("Final Configuration:")
print(final_config)
print("Mousepins:")
print(mousepins)
#=================================================================================================
# setup sensor
sensor.reset()
sensor.set_pixformat(sensor.GRAYSCALE)
sensor.set_framesize(sensor.QVGA)
sensor.skip_frames(time = 500)

sensor.set_transpose(final_config['to_transpose'])
sensor.set_hmirror(final_config['to_hmirror'])
sensor.set_windowing(final_config['sensor_window'])
clock = time.clock()
#=================================================================================================
# set params from text config
bodyThresh  = [final_config['mouse_thres_int']]
targetAngle = [math.pi/2, -math.pi/2]
myRegion    = [final_config['region_M1'], final_config['region_M2']]
colmouse    = [final_config['draw_M1'], final_config['draw_M2']]
locvec      = [final_config['platform_cent_M1'], final_config['platform_cent_M2']]
Rtrigger    = final_config['radius_M1_M2'] #8 for single, 10 for pairs
thetaRot    = math.radians(final_config['angle_requirement_deg']) # keep at 45
hisx        = final_config['history_alpha_x']
hisy        = final_config['history_alpha_y']
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
        mouseblob = img.find_blobs(bodyThresh, merge = True,
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
                thetacorrect = math.fabs(thetadiff) < thetaRot

                mdist = math.sqrt((mx - locvec[imouse][0])**2 + (my - locvec[imouse][1])**2)
                distcorr = mdist < Rtrigger[imouse]
                if thetacorrect and distcorr:
                    mouseinzone[imouse] = True
                    mousepins[imouse].value(True)
                    print("Mouse ", imouse+1," detected")
                else:
                    mousepins[imouse].value(False)
        else:
            n[imouse] = 0
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
