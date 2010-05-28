#!/usr/bin/env bash

# Copyright (c) 2009, Nikolas Coukouma. All rights reserved.
# Distributed under the terms of a BSD-style license. See COPYING for details.

# This script converts KinkOnTap episodes from their MPEG-4 (container) + AAC (audio)
# to MP3 and Vorbis (container) + Ogg (audio). It uses gstreamer to accomplish this.
# On Ubuntu, you'll need the following packages:
# gstreamer0.10-alsa (for vorbisenc, oggmux, filesink, filesrc)
# gstreamer0.10-tools (for gst-launch)
# gstreamer0.10-plugins-bad (for faad - AAC decoder)
# gstreamer0.10-ffmpeg (for ffdemux_mov_mp4_m4a_3gp_3g2_mj2)
# gstreamer0.10-plugins-ugly-multiverse (for lamemp3enc - MP3 encoder)
# gstreamer0.10-plugins-good (for id3v2mux - metadata muxer)

for i in $(ls *.m4a | sed -e s/\.m4a$//); do

  if [ ! -f $i.ogg ]; then
    echo "converting $i.m4a to $i.ogg"
    gst-launch-0.10 filesrc location=$i.m4a ! \
      ffdemux_mov_mp4_m4a_3gp_3g2_mj2 ! faad ! audioconvert ! \
      vorbisenc quality=0.15 ! oggmux ! filesink location=$i.ogg
  fi

  if [ ! -f $i.mp3 ]; then
    echo "converting $i.m4a to $i.mp3"
    gst-launch-0.10 filesrc location=$i.m4a ! \
      ffdemux_mov_mp4_m4a_3gp_3g2_mj2 ! faad ! audioresample ! \
      audio/x-raw-int, rate=44100 ! \
      lamemp3enc target=bitrate bitrate=64 ! id3v2mux ! \
      filesink location=$i.mp3
  fi

done
