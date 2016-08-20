#!/bin/sh
#### plvm-initialise v0.000 experimental
#script to initialise lvm2 logical volumes (lv)
#place in ~/Startup to run on boot, use separate script to mount eg. pmount-lvm-all.pl
dmsetup mknodes
vgscan --ignorelockingfailure
vgchange -ay --ignorelockingfailure
