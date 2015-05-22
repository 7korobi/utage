# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"

class Media::BDMV < Media::Handbrake
  def self.glob
    globbed  = Dir.glob("F://**/BDMV/index.bdmv").map {|s| s.gsub("/BDMV/index.bdmv","") }
    #globbed = Dir.glob("F://iso/**/*.ISO").reject {|s| s["DVD_VIDEO.ISO"] }
    track_scan(globbed)
  end

  def initialize(src, lang, title, audio, subtitle = nil)
    # @codec = %Q|-q 25 -e qsv_h264 --h264-level="4.2" --h264-profile=high -x target-usage=1:gop-ref-dist=4:gop-pic-size=32:async-depth=4|
    @codec = %Q|-q 25 -e x264 --h264-level="4.2" --h264-profile=high --pfr --detelecine --decomb --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
    @audio = %Q|-E av_aac -6 5point1 -R Auto -B 256 --audio-copy-mask aac|

    @ext  = %Q|--markers --title #{title} --audio #{audio}|
    @ext += %Q| --subtitle #{subtitle} --subtitle-burned| if subtitle

    @src = src
    path = @src[/^.*\/iso/]
    media_path @src.gsub(path,"").gsub(/.ISO$/, "") + "-#{lang}.mp4"

    # @target = %Q|//utage.family.jp/media/iPad/Videos/[映画] BD-src/#{paths[-1]}|
    puts "    [#{lang}] found.  #{@ext} "
  end
end
