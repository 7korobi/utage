# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"

class Media::BDMV < Media::Handbrake
  def self.glob
    globbed = Dir.glob("F://**/BDMV/index.bdmv").map {|s| s.gsub("/BDMV/index.bdmv","") }
    globbed += Dir.glob("F://iso/**/*.ISO")
    track_scan(globbed.reverse)
  end
end
