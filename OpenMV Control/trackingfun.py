# Untitled - By: usr_m_elbousta1 - Mon May 13 2024

import sensor

def save_background(fname):
    imgbkg = sensor.snapshot()
    imgbkg.save(fname)
