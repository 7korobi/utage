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
      initialize_hd
    when :SD
      initialize_sd
    end

    @ext  = %Q|--markers --title #{title} --audio #{audio}|
    @ext += %Q| --subtitle #{subtitle} --subtitle-burned| if subtitle
    @src  = src

    # @target = %Q|//utage.family.jp/media/iPad/Videos/[映画] BD-src/#{paths[-1]}|
    media_path out_path + "#{lang}.mp4"
    puts "    found #{size}#{lang}.  #{@ext} "
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

