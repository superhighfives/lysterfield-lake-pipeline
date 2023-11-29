#!/usr/bin/env ruby

def sys(cmd, *args, **kwargs)
  puts("\e[1m\e[33m#{cmd} #{args}\e[0m\e[22m")
  return system(cmd, *args, exception: true, **kwargs)
end

with_chromaprint = false

sys("brew", "uninstall", "--force", "--ignore-dependencies", "ffmpeg")

if with_chromaprint
  sys("brew", "install", "chromaprint", "amiaopensource/amiaos/decklinksdk")
end

sys("brew", "tap", "homebrew-ffmpeg/ffmpeg")
sys("brew", "install", "ffmpeg")
options = `brew options homebrew-ffmpeg/ffmpeg/ffmpeg`.split(/\n/).grep(/--with/)

# remove missing zvbi and decklink
options = options.grep_v(/zvbi/)
options = options.grep_v(/decklink/)

unless with_chromaprint
  options = options.grep_v(/chromaprint/)
end
sys("brew", "upgrade", "homebrew-ffmpeg/ffmpeg/ffmpeg", *options)