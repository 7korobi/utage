# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

module Media
  class Base
    BADWORDS = %w[
      FLSNOW RBF QTS LxyLab Lxy Lab A.A ReinForce ANK-raws Kuroi-raws Yousei-raws HorribleSubs philosophy-raws VCB-studio
      JPN
      720P 1080P TrueHD
      720x960 960x720 1080x1448 1080x1920 1440x1080 1448x1080 1920x816 1920x1080
      H264 x264 x264_aac x264-CHD.chs
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

    attr_accessor :src, :work, :target, :dir, :codec, :audio, :ext

    def self.filter(src)
      src = src.gsub(TAIL,"").gsub(NOIZE," ").gsub(POST_TRIM," ").gsub(/^-| -|- |-$/," ").gsub(POST_PREFIX,"\\2").gsub(/ +/," ").strip
      src = src.gsub(/\bIV\b/, "4").gsub(/\bVI\b/, "6").gsub(/\bV\b/, "5").gsub(/\bIII\b/, "3").gsub(/\bII\b/, "2")
    end

    def media_path(fname)
      paths = fname.split("/").reject {|str| [nil, ""].member? str }
      @work = ([ENV.work_dir] + paths[0..-1]).join("/")
      @dir  = ([ENV.work_dir] + paths[0..-2]).join("/") if paths.size > 1
    end

    def do_deploy
      raise "not implement"
    end

    def do_release
      raise "not implement"
    end

    def do_reject
      %Q|#{ENV.do_del} #{@work.path}|
    end

    def do_encode
      raise "not implement"
    end
  end
end
