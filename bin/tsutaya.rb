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

pack = Packer.new
pack.add Media::Movie.glob
pack.encode
pack.exec

