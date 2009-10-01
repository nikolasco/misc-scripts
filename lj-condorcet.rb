#!/usr/bin/env ruby

# Copyright (c) 2009, Nikolas Coukouma. All rights reserved.
# Distributed under the terms of a BSD-style license. See COPYING for details.

%w[rubygems curb set].each {|r| require r}

if ARGV.empty?
  puts "Usage:\n\tlj_condorcet.rb poll_url"
end

unless (m = ARGV[0].match(/[?&]id=(\d+)/))
  die "Couldn't determine the poll id from the given URL"
end

pid = m[1]
curl = Curl::Easy.new

curl.url = "http://www.livejournal.com/poll/?id=#{pid}"
curl.perform
qids = []
curl.body_str.scan(/lj_qid='(\d+)'/) {|m| qids << m[0].to_i}

picks = Hash.new
users = Set.new
opts = Set.new
qids.each do |q|
  curl.url = "http://www.livejournal.com/poll/?id=#{pid}&qid=#{q}&mode=ans"
  curl.perform
  curl.body_str.scan(/<div><span .*?<b>(\w+)<\/b><\/a><\/span> -- (.*?)<\/div>/) do |m|
    u, o = m.map {|s| s.intern}
    picks[u] ||= Hash.new 10**6
    picks[u][o] = q
    users << u
    opts << o
  end
end

scores = Hash.new
opts.each do |o1|
  opts.each do |o2|
    next if o1 == o2
    puts "#{o1} VERSUS #{o2}"
    s = 0
    users.each do |u|
      if picks[u][o1] < picks[u][o2]
        s += 1
      elsif picks[u][o1] > picks[u][o2]
        s -= 1
      else
        # tie
      end
    end
    puts "\t.. score #{s}"
    scores[o1] ||= Hash.new 0
    scores[o1][o2] = s
  end
end
puts "XXXXXXXXX"

order = opts.to_a.sort {|a, b| -scores[a][b] }
puts order
