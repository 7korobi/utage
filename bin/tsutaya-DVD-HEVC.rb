# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"
ENV.win

class Media::Base
  def self.scan_path
    "S://MEDIA/DVD/**"
  end
  def head_path
    @src[/^.*\/DVD/]
  end
end

class Media::HEVC
  def initialize(src, langs, title, size, audios, subtitles)
    case size
    when :HD
      initialize_hd
      @ext  = %Q|--markers --title #{title} --audio #{audios.uniq.join(",")}|
      @ext += %Q| --subtitle #{subtitles.uniq.join(",")}| if 0 < subtitles.length
    when :SD
      initialize_sd
      @ext  = %Q|--markers --audio 1,2,3,4,5,6,7,8,9 --subtitle 1,2,3,4,5,6,7,8,9 |
    end

    @src  = src

    media_path out_path + "-#{langs.join(",")}.mp4"
    puts "    found #{size}#{langs}.  #{@ext} "
  end

  def initialize_sd
    @codec = %Q|-q 27 -e x265_12bit --encoder-preset faster --encoder-tune "ssim" --encoder-profile main12 |
    @audio = %Q|-E av_aac -6 dpl2 -R Auto --aq 80 --audio-copy-mask aac|
  end
end

pack = Packer.new
pack.add Media::HEVC.glob
pack.encode
pack.exec

