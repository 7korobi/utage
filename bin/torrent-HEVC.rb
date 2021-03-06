# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"
ENV.win

class Media::Base
  def self.scan_path
    "S://MEDIA/BitTorrent/**"
  end
  def head_path
    @src[/^.*\/BitTorrent/]
  end
end

class Media::HEVC
  def initialize_hd
    @codec = %Q|-q 25 -e x265_12bit --encoder-preset veryfast --encoder-tune "ssim" --encoder-profile main12 |
    @audio = %Q|-E av_aac -6 5point1 -R Auto --aq 127 --audio-copy-mask aac|
  end
end

pack = Packer.new
pack.add Media::HEVC.glob
pack.encode
pack.exec

