# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"

class Media::BDMV < Media::Handbrake
  def self.glob
    globbed = Dir.glob(scan_path + "/BDMV/index.bdmv").map {|s| s.gsub("/BDMV/index.bdmv","") }
    track_scan globbed
  end

  def out_path
    @src.gsub(head_path,"").split("/").map{|str| Media::Base.filter str }.join("/")
  end

  def initialize_sd
    @codec = %Q|-q 28 --detelecine -e x265_12bit --h264-level="4.2"|
    @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 80 -D 0 --gain 0|
  end

  def initialize_hd
    # @codec = %Q|-q 24 -e x264 --h264-level="4.2" --h264-profile=high --vfr --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
    @codec = %Q|-q 23 -e x265_12bit --vfr --encoder-preset slower --encoder-tune "ssim" --encoder-profile main12 |
    @audio = %Q|-E av_aac -6 5point1 -R Auto --aq 127 --audio-copy-mask aac|
  end
end
