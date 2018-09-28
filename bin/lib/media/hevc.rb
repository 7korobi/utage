# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

Encoding.default_external = "utf-8"
require "open3"

class Media::HEVC < Media::Handbrake
  def self.glob
    globbed = Dir.glob(scan_path + "/*" + Media::Handbrake::MOVIE)
    track_scan globbed
  end

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

      langs     = []
      audios    = []
      subtitles = []
      invalid   = true
      all_audios = audio.split("\n")
      all_subs = subtitle.split("\n")
      begin
        subtitles.push all_subs.grep(/Japanese|日本語/)[0].match(/\+ (\d+)/)[1].to_i
        audios.push    all_audios.grep(/Chinese|中文/)[0].match(/\+ (\d+)/)[1].to_i
        langs.push     "ch"
        invalid = false
      rescue StandardError => e
      end
      begin
        subtitles.push all_subs.grep(/Japanese|日本語/)[0].match(/\+ (\d+)/)[1].to_i
        audios.push    all_audios.grep(/English/)[0].match(/\+ (\d+)/)[1].to_i
        langs.push     "en"
        invalid = false
      rescue StandardError => e
      end
      begin
        audios.push all_audios.grep(/Japanese|日本語/)[0].match(/\+ (\d+)/)[1].to_i
        langs.push  "ja"
      rescue StandardError => e
        if invalid && all_audios.size > 0
          audios.push all_audios[0].match(/\+ (\d+)/)[1].to_i
        else
          puts "    not find Japanese audio"
        end
      end
      list.push new(src, langs.reverse, title, size, audios.reverse, subtitles.reverse)
    end
    list
  end

  def initialize(src, langs, title, size, audios, subtitles)
    case size
    when :HD
      initialize_hd
    when :SD
      initialize_sd
    end

    @ext  = %Q|--markers --title #{title} --audio #{audios.uniq.join(",")}|
    @ext += %Q| --subtitle #{subtitles.uniq.join(",")}| if 0 < subtitles.length
    @src  = src

    media_path out_path + "-#{langs.join(",")}.mkv"
    puts "    found #{size}#{langs}.  #{@ext} "
  end

  def format
    %Q|-f av_mkv --vfr --loose-anamorphic --modulus 4|
  end

  def out_path
    @src.gsub(head_path,"").split("/").map{|str| Media::Base.filter str }.join("/")
  end

  def initialize_sd
    @codec = %Q|-q 26 -e x265_12bit --encoder-preset faster --encoder-tune "ssim" --encoder-profile main12 --detelecine |
    @audio = %Q|-E av_aac -6 dpl2 -R Auto --aq 80 --audio-copy-mask aac|
  end

  def initialize_hd
    @codec = %Q|-q 23 -e x265_12bit --encoder-preset faster --encoder-tune "ssim" --encoder-profile main12 |
    @audio = %Q|-E av_aac -6 5point1 -R Auto --aq 127 --audio-copy-mask aac|
  end
end
