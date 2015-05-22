# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

class Media::Handbrake < Media::Base
  CLI = "C://Program Files/Handbrake/HandBrakeCLI.exe"

  MOVIE = ".{AVI,WMV,MKV,MP4,M4V,F4V,TS,MTS,3GP}"

  def self.track_scan(globbed)
    list = []
    globbed.each do |src| 
      cmd = %Q|#{Media::Handbrake::CLI.path} -i #{src.path} --main-feature --scan|
      puts "scan... #{src}"
      o, e, s = Open3.capture3 cmd

      main = e.scrub.split(/\+ title /).find{|s| s[/  \+ Main Feature/] }
      video, audio, subtitle = main.split(/  \+ audio tracks:\n|  \+ subtitle tracks:\n/)
      title = main[/^\d+:/].to_i
      __, width, height = video.match(/  \+ size: (\d+)x(\d+)/).to_a.map(&:to_i)
      if width < 800 && height < 500
        size = :SD
      else
        size = :HD
      end

      ja = ""
      en = "-en"
      begin
        subtitle = subtitle.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        eng_audio = audio.split("\n").grep(/English/)[0].match(/\+ (\d+)/)[1].to_i
        list.push new(src, en, title, size, eng_audio, subtitle)
        ja = "-ja"
      rescue StandardError => e
        puts "    not find English audio or Japanese subs"
      end
      begin
        jpn_audio = audio.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        list.push new(src, ja, title, size, jpn_audio)
      rescue StandardError => e
        puts "    not find Japanese audio"
      end
    end
    list    
  end

  def initialize(src, lang, title, size, audio, subtitle = nil)
    case size
    when :HD
      # @codec = %Q|-q 25 -e qsv_h264 --h264-level="4.2" --h264-profile=high -x target-usage=1:gop-ref-dist=4:gop-pic-size=32:async-depth=4|
      @codec = %Q|-q 25 -e x264 --h264-level="4.2" --h264-profile=high --pfr --detelecine --decomb --encopts ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2|
      @audio = %Q|-E av_aac -6 5point1 -R Auto -B 256 --audio-copy-mask aac|
    when :SD
      @codec = %Q|-q 28 -e x265 --h264-level="4.2"|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
    end

    @ext  = %Q|--markers --title #{title} --audio #{audio}|
    @ext += %Q| --subtitle #{subtitle} --subtitle-burned| if subtitle

    @src = src
    path = @src[/^.*\/iso/]
    media_path @src.gsub(path,"").gsub(/.ISO$/, "") + "#{lang}.mp4"

    # @target = %Q|//utage.family.jp/media/iPad/Videos/[映画] BD-src/#{paths[-1]}|
    puts "    [#{lang}] found #{size}.  #{@ext} "
  end

  def do_deploy
    if @dir
      %Q|MKDIR #{@dir.path}|
    end
  end

  def do_release
    nil
  end

  def do_reject
    %Q|DEL #{@work.path}|
  end

  def do_encode
    format  = %Q|-P -f mp4 -4 --vfr --loose-anamorphic --modulus 4|

    if File.exists?(@work)
      %Q||
    else
      %Q|#{CLI.path} -i #{@src.path} -o #{@work.path} #{@ext} #{format} #{@audio} #{@codec} --verbose=1|
    end
  end
end

