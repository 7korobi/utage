# -*- encoding: utf-8 -*-


require "open3"

class Media
  BADWORDS = %w[
    FLSNOW RBF QTS LxyLab Lxy Lab A.A ANK-raws Kuroi-raws
    JPN
    720P 1080P TrueHD
    720x960 960x720 1080x1448 1080x1920 1440x1080 1448x1080 1920x816 1920x1080
    H264 x264 x264-CHD.chs
    Hi10P 320kbps
    FLAC FLACx2 ALAC AVC AC3 AAC 2.0+2.0
    DTS DTS-ES6.1
    BD BDrip BluRay Blu-ray
  ]
  NUMBERS = %w[
    Part
    BOX
    Vol\\.
    Vol
  ]
  TAIL = /\.[^.]+$/i
  NOIZE = /[_,']|[\[\]\(\)\{\}「」]/i
  POST_PREFIX = Regexp.new "\\b(#{NUMBERS.join("|")})(\\d*)\\b", Regexp::IGNORECASE
  POST_TRIM = Regexp.new "\\b(#{BADWORDS.join("|")})\\b", Regexp::IGNORECASE
  STAMP = Time.now.strftime("%Y-%m-%d.%H")

  attr_accessor :src, :work, :target, :dir, :codec, :audio, :ext

  def self.bat
    "D://MEDIA/BitTorrent/bat/#{STAMP}-release.bat"
  end

  def self.filter(src)
    src = src.gsub(TAIL,"").gsub(NOIZE," ").gsub(POST_TRIM," ").gsub(/^-| -|- |-$/," ").gsub(POST_PREFIX,"\\2").gsub(/ +/," ").strip
    src = src.gsub(/\bIV\b/, "4").gsub(/\bVI\b/, "6").gsub(/\bV\b/, "5").gsub(/\bIII\b/, "3").gsub(/\bII\b/, "2")
  end

  
  def self.movies
    Dir.glob("{D,F}://UTAGE-MEDIA/BitTorrent/**/*" + Handbrake::MOVIE).map{|o| Media.new.movie(o) } 
  end

  def movie(src)
    @ext = ""
    case src[TAIL]
    when ".AVI", ".avi"
      @codec = %Q|-q 28 -e x265 --h264-level="4.2"|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 64 -D 0 --gain 0|
    else
      @codec = %Q|-q 25 -e qsv_h264 --h264-level="4.2" --h264-profile=high -x target-usage=1:gop-ref-dist=4:gop-pic-size=32:async-depth=4|
      @audio = %Q|-E av_aac -6 dpl2 -R Auto -B 256 --audio-copy-mask aac|
    end

    @src = src
    path  = src[/^.*\/BitTorrent/]
    fname = src.gsub(path,"").split("/").map{|str| Media.filter str }.join("/") + ".mp4"
    @work = Handbrake.work_dir + fname
    paths = @work.split("/")
    @dir  = paths[0..-2].join("/")

    @target = %Q|//utage.family.jp/media/iPad/Videos/#{paths[-2]}/#{paths[-1]}|

    self
  end


  def self.bdmvs
    list = []
    globbed  = Dir.glob("F://iso/**/*.ISO").reject {|s| s["DVD_VIDEO.ISO"] }
    globbed += Dir.glob("F://**/BDMV/index.bdmv").map {|s| s.gsub("/BDMV/index.bdmv","") }
    globbed.each do |src| 
      cmd = %Q|#{Handbrake::CLI.path} -i #{src.path} --main-feature --scan|
      puts cmd
      o, e, s = Open3.capture3 cmd
      main = e.scrub.split(/\+ title /).find{|s| s[/  \+ Main Feature/] }
      __, audio, subtitle = main.split(/  \+ audio tracks:\n|  \+ subtitle tracks:\n/)
      title = main[/^\d+:/].to_i
      begin
        subtitle = subtitle.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        eng_audio = audio.split("\n").grep(/English/)[0].match(/\+ (\d+)/)[1].to_i
        list.push Media.new.bdmv(src, "en", title, eng_audio, subtitle)
      rescue
      end
      begin
        jpn_audio = audio.split("\n").grep(/Japanese/)[0].match(/\+ (\d+)/)[1].to_i
        list.push Media.new.bdmv(src, "ja", title, jpn_audio)
      rescue
      end
    end
    list
  end

  def bdmv(src, lang, title, audio, subtitle = nil)
    p [src, lang, title, audio, subtitle]
    @codec = %Q|-q 23 -e qsv_h264 --h264-level="4.2" --h264-profile=high -x target-usage=1:gop-ref-dist=4:gop-pic-size=32:async-depth=4|
    @audio = %Q|-E av_aac -6 5point1 -R Auto -B 256 -D 0 --gain 0|
    @ext  = %Q|--markers --title #{title} --audio #{audio}|
    @ext += %Q| --subtitle #{subtitle} --subtitle-burned| if subtitle

    @src = src
    path  = @src[/^.*\/iso/]
    fname = @src.gsub(path,"").gsub(/.ISO$/, "") + "-#{lang}.mp4"
    @work = Handbrake.work_dir + fname
    paths = @work.split("/")
    @dir  = paths[0..-2].join("/")

    @target = %Q|//utage.family.jp/media/iPad/Videos/[映画] BD-src/#{paths[-1]}|

    self
  end
end

class Handbrake
  STAMP = Time.now.strftime("%Y-%m-%d.%H")
  CLI = "C://Program Files/Handbrake/HandBrakeCLI.exe"

  MOVIE = ".{AVI,WMV,MKV,MP4,M4V,F4V}"
  AUDIO = ".{wma,flac}"
  COPY = ".{mp3,jpg,jpeg,png,zip}"
  ARC = ".{lzh,rar}"

  def self.work_dir
    "C://MEDIA/WORK"
  end

  def self.bat
    "D://MEDIA/BitTorrent/bat/#{STAMP}-encode.bat"
  end

  def self.log
    "D://MEDIA/BitTorrent/log/#{STAMP}-encode.log"
  end

  def initialize
    @list = []
    @deploys  = []
    @commands = []
    @releases = []
  end

  def add(list)
    @list += list
  end

  def exec
    open(Handbrake.bat, "w") do |f|
      (@deploys.sort.uniq + [""] + @commands.uniq).each do |cmd|
        `#{cmd}` if cmd.size > 0
        f.puts cmd
      end
    end
    open(Media.bat, "w") do |f|
      (@releases.sort.uniq).each do |cmd|
        puts cmd
        f.puts cmd
      end
    end
  end

  def deploy(cmd)
    @deploys.push(cmd)
  end

  def command(cmd)
    @commands.push(cmd)
  end

  def release(cmd)
    @releases.push(cmd)
  end

  def encode
    @list.each do |media|
      format  = %Q|-P -U -f mp4 -4 --vfr --loose-anamorphic --modulus 4|

      open(Handbrake.log, "a") do |f|
        f.puts media.src
        f.puts media.work
      end

      deploy  %Q|mkdir #{media.dir.path}|
      command %Q|#{CLI.path} -i #{media.src.path} -o #{media.work.path} #{media.ext} #{format} #{media.audio} #{media.codec} --verbose=1 && echo "done #{media.src}" #{Handbrake.log}|
      release %Q|move #{media.work.path} #{media.target.path}|
      release %Q|delete #{media.src.path}|
    end
  end

  def `(cmd)
    super
  end
end

class String
  def path
    win = self.gsub(/:\/\//,':\\').gsub(/\//,'\\')
    %Q|"#{win}"|
  end
end


