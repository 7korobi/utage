# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"
ENV.win

class Media::Base
  def self.scan_path
    "S://MEDIA/BitTorrent-BD/**"
  end
  def head_path
    @src[/^.*\/BitTorrent-BD/]
  end
end


pack = Packer.new
pack.add Media::BDMV.glob 
pack.encode
pack.exec

