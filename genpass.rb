#!/usr/bin/env ruby

# Copyright (c) 2009, Nikolas Coukouma. All rights reserved.
# Distributed under the terms of a BSD-style license. See COPYING for details.

# This is a simple script to generate throwaway passwords

RAND_FILE = "/dev/urandom"
PASS_LEN = 8
CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

puts File.read(RAND_FILE, PASS_LEN).split(//).
  map {|r| CHARS[r[0]%CHARS.length, 1] }.join('')
