# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

require "open3"
require "./lib/media"

class Packer
  AUDIO = ".{wma,flac}"
  COPY = ".{mp3,jpg,jpeg,png,zip}"
  ARC = ".{lzh,rar}"

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
    puts e
    s
  end

  def exec
    open(ENV.deploy_log, "w") do |f|
      @sources.map {|item| item.do_deploy }.compact.uniq.sort.each do |cmd|
        do_exec f, cmd
      end

      @releases = []
      @sources.each do |item|
        begin
          cmd = item.do_encode
          if cmd
            if do_exec(f, cmd + " || " + item.do_reject).success?
              @releases.push item.do_release
            end
          else
            @releases.push item.do_release
          end
        rescue Interrupt => e
          do_exec f, item.do_reject
          raise e
        end
      end
    end
    open(ENV.release_log, "w") do |f|
      @releases.compact.uniq.sort.each do |cmd|
        do_exec f, cmd
      end
    end
  end
end
