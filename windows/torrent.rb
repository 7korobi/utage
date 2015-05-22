# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"

pack = Packer.new
pack.add Media::BDMV.glob
pack.add Media::Movie.glob
pack.encode
pack.exec

