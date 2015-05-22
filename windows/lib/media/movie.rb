# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

class Media::Movie < Media::Handbrake
  def self.glob
    globbed = Dir.glob("{D,F}://UTAGE-MEDIA/BitTorrent/**/*" + Media::Handbrake::MOVIE)
    track_scan(globbed)
  end

  def initialize(src)
    @ext = ""
    size = File.size(src) rescue 301_000_000
    case size
    when 0..350_000_000
      @codec = %Q|-q 28 -e x265 --h264-level="4.2"|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
    else
      @codec = %Q|-q 25 -e x264 --h264-level="4.2" --h264-profile=high --pfr --detelecine --decomb --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 256 --audio-copy-mask aac|
    end

    @src = src
    path  = src[/^.*\/BitTorrent/]
    media_path src.gsub(path,"").split("/").map{|str| Media::Base.filter str }.join("/") + ".mp4"

    # @target = %Q|//utage.family.jp/media/iPad/Videos/#{paths[-2]}/#{paths[-1]}|
  end
end