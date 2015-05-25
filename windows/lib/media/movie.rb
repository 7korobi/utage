# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"

class Media::Movie < Media::Handbrake
  def self.glob
    globbed = Dir.glob("{D,F}://UTAGE-MEDIA/BitTorrent/**/*" + Media::Handbrake::MOVIE)
    track_scan(globbed)
  end

  def out_path
    @src.gsub(@src[/^.*\/BitTorrent/],"").split("/").map{|str| Media::Base.filter str }.join("/")
  end

  def initialize_sd
    @codec = %Q|-q 28 --detelecine -e x265 --h264-level="4.2"|
    @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
  end

  def initialize_hd
    # @codec = %Q|-q 25 -e qsv_h264 --h264-level="4.2" --h264-profile=high -x target-usage=1:gop-ref-dist=4:gop-pic-size=32:async-depth=4|
    @codec = %Q|-q 25 -e x264 --h264-level="4.2" --h264-profile=high --vfr --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
    @audio = %Q|-E av_aac -6 5point1 -R Auto -B 256 --audio-copy-mask aac|
  end
end
