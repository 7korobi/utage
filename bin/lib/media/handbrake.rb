# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

class Media::Handbrake < Media::Base
  MOVIE = ".{AVI,WMV,MKV,MOV,MP4,M4V,F4V,TS,MTS,M2TS,3GP,FLV,ISO}"

  def self.track_scan(globbed)
    list = []
    globbed.each do |src|
      cmd = %Q|#{ENV.cli.path} -i #{src.path} --main-feature --scan|
      puts "scan... #{src}"
      o, e, s = Open3.capture3 cmd
      titles = e.scrub.split(/\+ title /i)
      main = titles.find{|s| s[/  \+ Main Feature/] } || titles.find{|s| s[/^1\:/] }
      next unless main

      video, audio, subtitle = main.split(/  \+ audio tracks:\n|  \+ subtitle tracks:\n/)
      title = main[/^\d+:/].to_i
      __, width, height = video.match(/  \+ size: (\d+)x(\d+)/).to_a.map(&:to_i)
      if width < 800 && height < 500
        size = :SD
      else
        size = :HD
      end

      ja = ""
      en = ""
      ch = ""
      begin
        jpn_subtitle = subtitle.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        chi_audio = audio.split("\n").grep(/Chinese/)[0].match(/\+ (\d+)/)[1].to_i
        ch = "-ch"
        list.push new(src, ch, title, size, chi_audio, jpn_subtitle)
        ja = "-ja"
      rescue StandardError => e
      end
      begin
        jpn_subtitle = subtitle.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        eng_audio = audio.split("\n").grep(/English/)[0].match(/\+ (\d+)/)[1].to_i
        en = "-en"
        list.push new(src, en, title, size, eng_audio, jpn_subtitle)
        ja = "-ja"
      rescue StandardError => e
      end
      begin
        jpn_audio = audio.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        list.push new(src, ja, title, size, jpn_audio)
      rescue StandardError => e
        if "" == en && "" == ch
          jpn_audio = audio.split("\n")[0].match(/\+ (\d+)/)[1].to_i
          list.push new(src, ja, title, size, jpn_audio)
        else
          puts "    not find Japanese audio"
        end
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

  def format
    %Q|-f mp4 -4 --vfr --loose-anamorphic --modulus 4|
  end

  def do_deploy
    if @dir
      %Q|mkdir #{@dir.path}|
    end
  end

  def do_release
    nil
  end

  def do_encode
    if File.exists?(@work)
      nil
    else
      %Q|#{ENV.cli.path} -i #{@src.path} -o #{@work.path} #{@ext} #{format} #{@audio} #{@codec} --verbose=1|
    end
  end
end
