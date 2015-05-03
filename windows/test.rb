# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib"

movie = Handbrake.new
movie.add Media.bdmvs
movie.add Media.movies
movie.encode
movie.exec

