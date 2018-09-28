# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

TAGS = {}

def move_temp(src_dir)
  tmp = ENV.tmp_dir + "/"
  Dir.glob(src_dir).each do |src|
    puts "   ... copy by #{src.path}"
    time = File.mtime src
    `mv #{src.path} #{tmp.path}`
    File.utime time, time, tmp
  end
end

module Media::Album
  def tag(mtime)
    datestamp = mtime.strftime("%Y-%m-%d")

    TAGS[datestamp] ||= begin
      time_of_day = 1 * 24*60*60
      minami   = ((mtime - Time.new(2013, 6,24, 5)) / time_of_day).ceil
      tomohiro = ((mtime - Time.new(1978, 7,25, 4)) / time_of_day).ceil
      mika     = ((mtime - Time.new(1980,11, 6,12)) / time_of_day).ceil
      puts "### input comment at #{datestamp}  minami:#{minami}days. mika:#{mika}days. tomohiro:#{tomohiro}days. ###"
      `open #{@src.path}`
      gets.chomp
    end
  end

  def out_path
    mtime = File.mtime(@src)
    timestamp = mtime.strftime("%Y-%m-%d.%H.%M.%S")
    tag(mtime) + "-" + timestamp
  end
end

class Media::AlbumPhoto < Media::Copy
  include Media::Album
  def self.glob
    move_temp(scan_path + "/*" + Media::Copy::PICTURE)
    globbed = Dir.glob(ENV.tmp_dir + "/**/*" + Media::Copy::PICTURE)
    photo_scan globbed
  end

  def do_release
    %Q|rm #{@src.path}|
  end
end

class Media::AlbumAVCHD < Media::Copy
  include Media::Album
  def self.glob
    globbed = Dir.glob(ENV.tmp_dir + "**/*" + Media::Handbrake::MOVIE)
    photo_scan globbed
  end

  def do_release
    %Q|rm #{@src.path}|
  end
end

class Media::AlbumMovie < Media::Handbrake
  include Media::Album
  def self.glob
    move_temp(scan_path + "/*" + Media::Handbrake::MOVIE)
    globbed = Dir.glob(ENV.tmp_dir + "/**/*" + Media::Handbrake::MOVIE)
    track_scan globbed
  end

  def initialize_sd
    @codec = %Q|-q 28 --detelecine -e x265_12bit --h264-level="4.2"|
    @audio = %Q|-E ca_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
  end

  def initialize_hd
    @codec = %Q|-q 23 -e x264 --h264-level="4.2" --h264-profile=high --vfr --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
    @audio = %Q|-E ca_aac -6 5point1 -R Auto -B 256 --audio-copy-mask aac|
  end
end
