# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "./lib/media/base"
require "./lib/media/copy"
require "./lib/media/handbrake"

require "./lib/media/bdmv"
require "./lib/media/album"
require "./lib/media/movie"
require "./lib/media/hevc"


STAMP = Time.now.strftime("%Y-%m-%d.%H")
ENV = Struct.new(:cli, :tmp_dir, :work_dir, :deploy_log, :release_log, :do_del).new
def ENV.win
  ENV.cli = "C://Dropbox/bin/HandBrakeCLI.exe"
  ENV.work_dir = "S://MEDIA/WORK"
  ENV.deploy_log = "S://MEDIA/BitTorrent/bat/#{STAMP}-encode.bat"
  ENV.release_log = "S://MEDIA/BitTorrent/bat/#{STAMP}-release.bat"
  ENV.do_del = "DEL"
  def ENV.path(str)
    win = str.gsub(/:\/\//,':\\').gsub(/\//,'\\')
    %Q|"#{win}"|
  end
end

def ENV.mac
  ENV.cli = "/www/bin/HandBrakeCLI"
  ENV.work_dir = ""
  ENV.deploy_log = "/tmp/#{STAMP}-encode.bat"
  ENV.release_log = "/tmp/#{STAMP}-release.bat"
  ENV.do_del = "rm"
  def ENV.path(str)
    %Q|"#{str}"|
  end
end

class String
  def path
  	ENV.path(self)
  end
end
