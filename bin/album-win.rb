#! rbenv exec ruby
# -*- encoding: utf-8 -*-

require "./lib/packer"
ENV.win

head = %r=^Z:/Album/(Photo|Videos/AVCHD)/=
glob = %Q|Z:/Album/{Photo,Videos/AVCHD}/**/|

puts Dir.glob(glob).map{|o| o.gsub(head,"").chop }.uniq.sort

class Media::AlbumMovie
  def self.scan_path
    "S:/AVCHD/*/STREAM/**"
  end
  def head_path
    @src[/^.*\/STREAM/]
  end
end

class Media::AlbumPhoto
  def self.scan_path
    "F:/DCIM/**"
  end
  def head_path
    @src[/^.*\/DCIM/]
  end
end

pack = Packer.new

ENV.tmp_dir  = "S:/MEDIA/PIC"
ENV.work_dir = "Z:/Album/Photo"
pack.add Media::AlbumPhoto.glob

ENV.tmp_dir  = "S:/MEDIA/MOV/AVCHD"
ENV.work_dir = "S:/MEDIA/MOV/HandBrake"
pack.add Media::AlbumMovie.glob

ENV.work_dir = "Z:/Album/Videos/AVCHD"
pack.add Media::AlbumAVCHD.glob

pack.encode
pack.exec
