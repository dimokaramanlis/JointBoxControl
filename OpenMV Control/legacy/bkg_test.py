# This work is licensed under the MIT license.
# Copyright (c) 2013-2023 OpenMV LLC. All rights reserved.
# https://github.com/openmv/openmv/blob/master/LICENSE
#
# Advanced Frame Differencing Example
#
# This example demonstrates using frame differencing with your OpenMV Cam. This
# example is advanced because it performs a background update to deal with the
# background image changing overtime.

import sensor
import time
import os, image


TRIGGER_THRESHOLD = 60

BG_UPDATE_FRAMES = 200  # How many frames before blending.
BG_UPDATE_BLEND = 10  # How much to blend by... ([0-256]==[0.0-1.0]).

thresholds_body = [(100,255)]    # Ciseaux
windowvals      = [90,20,140,220]
fname = "bg.bmp"


sensor.reset()  # Initialize the camera sensor.
sensor.set_pixformat(sensor.GRAYSCALE)  # or sensor.RGB565
sensor.set_vflip(True)
sensor.set_transpose(True)
sensor.set_framesize(sensor.QVGA)  # or sensor.QQVGA (or others)
sensor.skip_frames(time=2000)  # Let new settings take affect.
sensor.set_windowing(windowvals)
sensor.set_auto_whitebal(False)  # Turn off white balance.
clock = time.clock()  # Tracks FPS.

print(os.listdir())
if not "temp" in os.listdir():
    os.mkdir("temp")  # Make a temp directory

# Take from the main frame buffer's RAM to allocate a second frame buffer.
# There's a lot more RAM in the frame buffer than in the MicroPython heap.
# However, after doing this you have a lot less RAM for some algorithms...
# So, be aware that it's a lot easier to get out of RAM issues now. However,
# frame differencing doesn't use a lot of the extra space in the frame buffer.
# But, things like AprilTags do and won't work if you do this...
extra_fb  = sensor.alloc_extra_fb(windowvals[3], windowvals[2], sensor.GRAYSCALE)
fb_ori    = sensor.alloc_extra_fb(windowvals[3], windowvals[2], sensor.GRAYSCALE)

myRegion_M1 = [0,  4,  220, 63]
myRegion_M2 = [0 , 69,  220, 65]
#---------------------------------------------------------------------
print("About to save background image...")
imgbkg = sensor.snapshot()
if not fname in os.listdir("temp"):
    imgbkg.save("temp/bg.bmp")
else:
    imgdisk = image.Image("temp/bg.bmp")
    if imgdisk.size() == imgbkg.size():
        imgbkg = imgdisk
    else:
         imgbkg.save("temp/bg.bmp")
print("Saved background image - Now frame differencing!")
#---------------------------------------------------------------------
triggered = False

frame_count = 0

while True:
    clock.tick()  # Track elapsed milliseconds between snapshots().
    img = sensor.snapshot()  # Take a picture and return the image.

    fb_ori.replace(img) #keep a copy of current frame
    #---------------------------------------------------------------------
    frame_count += 1
    if frame_count > BG_UPDATE_FRAMES and triggered:
        frame_count = 0
        # Blend in new frame. We're doing 256-alpha here because we want to
        # blend the new frame into the background. Not the background into the
        # new frame which would be just alpha. Blend replaces each pixel by
        # ((NEW*(alpha))+(OLD*(256-alpha)))/256. So, a low alpha results in
        # low blending of the new image while a high alpha results in high
        # blending of the new image. We need to reverse that for this update.
        imgbkg.blend(img, alpha=(256 - BG_UPDATE_BLEND))
    #---------------------------------------------------------------------
    # Replace the image with the "abs(NEW-OLD)" frame difference.
    img.difference(imgbkg)
    img.median(2)
    #hist = img.get_histogram()
    # This code below works by comparing the 99th percentile value (e.g. the
    # non-outlier max value against the 90th percentile value (e.g. a non-max
    # value. The difference between the two values will grow as the difference
    # image seems more pixels change.
    #diff = hist.get_percentile(0.99).l_value() - hist.get_percentile(0.90).l_value()
    #triggered = diff > TRIGGER_THRESHOLD

    bloblist = img.find_blobs(thresholds_body, pixels_threshold=80, area_threshold=80, merge=True)
    triggered = False
    img.replace(fb_ori)
    for blob in bloblist:
        img.draw_edges(blob.min_corners(), color = (180,180,180))
        triggered = triggered or abs(blob.cxf()-myRegion_M1[0])<40 or abs(blob.cxf()-(myRegion_M1[0]+myRegion_M1[2]))<40


    #print(clock.fps(), triggered, diff)  # Note: Your OpenMV Cam runs about half as fast while
    # connected to your computer. The FPS should increase once disconnected.
