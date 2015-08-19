#! rbenv exec ruby
# -*- encoding: utf-8 -*-

require "./lib/packer"
ENV.mac

head = %r=^/Volumes/media/Album/(Photo|Videos/AVCHD)/=
glob = %Q|/Volumes/media/Album/{Photo,Videos/AVCHD}/**/|

puts Dir.glob(glob).map{|o| o.gsub(head,"").chop }.uniq.sort

class Media::AlbumMovie
  def self.scan_path
    "/Volumes/*/AVCHD/*/STREAM/**"
  end
  def head_path
    @src[/^.*\/STREAM/]
  end
end

class Media::AlbumPhoto
  def self.scan_path
    "/Volumes/*/DCIM/**"
  end
  def head_path
    @src[/^.*\/DCIM/]
  end
end

pack = Packer.new

ENV.tmp_dir  = "/Users/7korobi/Pictures/CAMERA"
ENV.work_dir = "/Volumes/media/Album/Photo"
pack.add Media::AlbumPhoto.glob

ENV.tmp_dir  = "/Users/7korobi/Movies/AVCHD"
ENV.work_dir = "/Users/7korobi/Movies/HandBrake"
pack.add Media::AlbumMovie.glob

ENV.work_dir = "/Volumes/media/Album/Videos/AVCHD"
pack.add Media::AlbumAVCHD.glob

pack.encode
pack.exec
