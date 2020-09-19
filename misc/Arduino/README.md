# Miscellaneous Arduino and related functions

## Contents

### Scripts

These scripts (written by Andrey Andreev) are used with the TFC-scope to perform TFC behavioral experiments. Each of these files contains a script that was created and tested in Arduino IDE (versions 1.8.7, 1.8.8, and 1.8.9) or in the command environment of a PC running Windows 7. 

1. heat_LED_conditioning.ino is an Arduino IDE script that runs the behavior training protocol with a properly configured Arduino board and TFC scope. The script runs through all of the blocks of the TFC protocol (habituation, training, testing, and re-training). The Arduino controls the green LED (conditioned stimulus, CS), the near infrared heating laser (unconditioned stimulus, US), and the multi-level near infrared LED (for indicating when the CS and/or US are on). Note that the values used here for each of the stimuli should be tuned for each TFC scope (e.g., the level of power used for heating).
2. multilevelIR.ino is an Arduino IDE script for a separate Arduino board that goes along with heat_LED_conditioning.ino in the TFC protocol. This script is strictly used to set the levels of the multi-level near infrared LED that gives indications for when the CS and/or US are on. Note that these values should be tuned for each individual TFC scope, since conditions may be slightly different as far as contrast on the images.
3. ffmpeg_concat.cmd and ffmpeg_concatenate.rb are command line scripts used (in the command line on a PC running Windows 7) to convert a folder full of individual, sequentially-named image files into a single .mp4 file that can be analyzed with software in the main [fishspy](https://github.com/informatics-isi-edu/fishspy) repo.
