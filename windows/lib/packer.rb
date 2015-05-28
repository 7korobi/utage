# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"
require "./lib/media"

class Packer
  AUDIO = ".{wma,flac}"
  COPY = ".{mp3,jpg,jpeg,png,zip}"
  ARC = ".{lzh,rar}"

  STAMP = Time.now.strftime("%Y-%m-%d.%H")
  WORK_DIR = "C://MEDIA/WORK"
  DEPLOY_LOG = "D://MEDIA/BitTorrent/bat/#{STAMP}-encode.bat"
  RELEASE_LOG = "D://MEDIA/BitTorrent/bat/#{STAMP}-release.bat"

  def initialize
    @sources  = []
    @deploys  = []
    @commands = []
    @releases = []
  end

  def add(list)
    @sources += list
  end

  def encode
  end

  def do_exec(log, cmd)
    return unless cmd
    log.puts cmd
    puts cmd
    o, e, s = Open3.capture3 cmd
    p s
    puts e
  end

  def exec
    open(DEPLOY_LOG, "w") do |f|
      @sources.map {|item| item.do_deploy }.compact.uniq.sort.each do |cmd|
        do_exec f, cmd
      end

      @sources.each do |item|
        begin
          do_exec f, item.do_encode + " || " + item.do_reject 
        rescue Interrupt => e
          do_exec f, item.do_reject 
          raise e
        end
      end
    end
    open(RELEASE_LOG, "w") do |f|
      @sources.map {|item| item.do_release }.compact.uniq.sort.each do |cmd|
        do_exec f, item.do_reject 
      end
    end
  end
end
