# -*- encoding: utf-8 -*-
# set RUBYOPT=-EUTF-8

class Media::Copy < Media::Base
  PICTURE = ".{jpg,jpeg,png}"

  def self.photo_scan(globbed)
    list = []
    globbed.each do |src|
      list.push new(src)
    end
    list
  end

  def initialize(src)
    ext = src[/\.[^.]+$/]
    @src = src
    media_path out_path + ext
  end

  def do_deploy
    if @dir
      %Q|MKDIR #{@dir.path}|
    end
  end

  def do_release
    nil
  end

  def do_encode
    if File.exists?(@work)
      nil
    else
      %Q|cp #{@src.path} #{@work.path}|
    end
  end
end
