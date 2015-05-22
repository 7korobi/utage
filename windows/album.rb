# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/packer"

pack = Packer.new
pack.add Media::Album.glob
pack.encode
pack.exec

