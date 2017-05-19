# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"
ENV.win

class Media::Base
  def self.scan_path
    "S://MEDIA/BD/Video/**"
  end
  def head_path
    @src[/^.*\/Video/]
  end
end

class Media::HEVC
  def initialize_hd
    @codec = %Q|-q 23 -e x265 --encoder-preset faster --encoder-tune "ssim" --encoder-profile main10 |
    @audio = %Q|-E av_aac -6 5point1 -R Auto --aq 127 --audio-copy-mask aac|
  end
end

pack = Packer.new
pack.add Media::HEVC.glob
pack.encode
pack.exec

