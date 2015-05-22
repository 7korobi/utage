# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"

class Media::DVD < Media::Handbrake
  def self.glob
    list = []
    globbed = Dir.glob("F://iso/**/DVD_VIDEO.ISO").reject {|s| s["DVD_VIDEO.ISO"] }
    track_scan(globbed)
  end

  def initialize(src, lang, title, audio, subtitle = nil)
    @codec = %Q|-q 28 -e x265 --h264-level="4.2"|
    @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|

    @ext  = %Q|--markers --title #{title} --audio #{audio}|
    @ext += %Q| --subtitle #{subtitle} --subtitle-burned| if subtitle

    @src = src
    path = @src[/^.*\/iso/]
    media_path @src.gsub(path,"").gsub(/\/DVD_VIDEO.ISO$/, "") + "-#{lang}.mp4"

    # @target = %Q|//utage.family.jp/media/iPad/Videos/[映画] BD-src/#{paths[-1]}|
    puts "    [#{lang}] found.  #{@ext} "
  end
end
