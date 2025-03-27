# Untitled - By: Your Name - Thu Mar 27 2025

import sensor
import time
import os
import openmv_funs

# ---- Configuration ----
SAVE_PATH = '\mouse_frames_test'  # Base directory on SD card to save frames
SAVE_EVERY_N_FRAMES = 30      # Save every Nth frame. Set to 1 to save all frames.
#=================================================================================================
config_filename = "config.txt"
final_config = openmv_funs.read_config_file(config_filename)
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
sensor.skip_frames(time = 500)
sensor.set_brightness(final_config['sensor_brightness'])
clock = time.clock()
#=================================================================================================

print(f"Saving frames to: {SAVE_PATH}")
print(f"Saving every {SAVE_EVERY_N_FRAMES} frame(s).")

# --- Ensure Save Directory Exists ---
try:
    os.stat(SAVE_PATH)
    print(f"Base directory {SAVE_PATH} already exists.")
except OSError:
    print(f"Creating base directory {SAVE_PATH}...")
    try:
        os.mkdir(SAVE_PATH)
    except Exception as e:
        print(f"Error creating directory: {e}")
        raise # Stop if we can't create the directory

# --- Frame Capture Loop ---
processed_frame_num = 0 # Counts all frames processed by the camera
saved_frame_count = 0   # Counts only the frames actually saved
print("Starting frame capture. Press Ctrl+C in the terminal to stop.")

try:
    while(True):
        clock.tick()                     # Update the FPS clock.
        img = sensor.snapshot()          # Take a picture and return the image.
        processed_frame_num += 1

        # Check if it's time to save this frame based on SAVE_EVERY_N_FRAMES
        if (processed_frame_num % SAVE_EVERY_N_FRAMES == 0):
            saved_frame_count += 1 # Increment counter for saved frames

            # Construct filename with session timestamp and saved frame sequence number
            # Example: /mouse_frames/frame_20250327_020550_00001.jpg
            filename = f"{SAVE_PATH}/frame_{saved_frame_count:05d}.jpg"

            # Save the image
            # Quality setting (0-100, higher is better/larger file). 90 is a good balance.
            print(f"Saving {filename} (Processed frame: {processed_frame_num})")
            try:
                img.save(filename, quality=90)
            except Exception as e:
                print(f"Error saving file {filename}: {e}")
                # Decide how to handle errors: continue, stop, etc.
                # For now, just print the error and continue
                # You might run out of SD card space!

        # Optional: Add a small delay if needed
        # time.sleep_ms(50)

        # Optional: Print FPS
        # print(f"FPS: {clock.fps():.2f}")

except KeyboardInterrupt:
    print("\nFrame capture stopped by user.")
    print(f"Total frames processed: {processed_frame_num}")
    print(f"Total frames saved in this session: {saved_frame_count}")
    if saved_frame_count > 0:
        print(f"Last saved frame number: {saved_frame_count}")
