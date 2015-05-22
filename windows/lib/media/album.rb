# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

class Media::Album < Media::Handbrake
  def self.glob
    Dir.glob("{G}://AVCHD/*/STREAM/*" + Media::Handbrake::MOVIE).map{|o| new(o) } 
  end

  def initialize(src)
    @ext = ""
    size = File.size(src) rescue 301_000_000
    case size
    when 0..1_000_000_000
      @codec = %Q|-q 28 -e x265 --h264-level="4.2"|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
    else
      @codec = %Q|-q 25 -e x264 --h264-level="4.2" --h264-profile=high --pfr --detelecine --decomb --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 256 --audio-copy-mask aac|
    end

    time_of_day = 1 * 24*60*60
    mtime = File.mtime(src)
    minami   = (mtime - Time.new(2013, 6,24, 5) / time_of_day).ceil
    tomohiro = (mtime - Time.new(1978, 7,25, 4) / time_of_day).ceil
    mika     = (mtime - Time.new(1980,11, 6,12) / time_of_day).ceil

    @src = src
    media_path ["#{mtime.strftime("%Y-%m-%d")} = #{minami}days", "#{mtime.strftime("%H-%M-%S")}"].join("/") + ".mp4"

    # @target = %Q|//utage.family.jp/media/iPad/Videos/#{paths[-2]}/#{paths[-1]}|
  end
end