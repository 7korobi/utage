# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/media/base"
require "./lib/media/picture"
require "./lib/media/handbrake"
require "./lib/media/bdmv"
require "./lib/media/album"
require "./lib/media/movie"

class String
  def path
    win = self.gsub(/:\/\//,':\\').gsub(/\//,'\\')
    %Q|"#{win}"|
  end
end

