#!/usr/bin/env ruby

PATH = {
  IPAD_CP: "/Users/7korobi/Pictures/iPad*",
  QTIME:   "/Users/7korobi/Movies/QUICK",
  NAS_QT:  "/Volumes/media/Album/Videos/QUICK",

  CAM_JPG: "/Volumes/*/DCIM/*",
  PHOTO:   "/Users/7korobi/Pictures/CAMERA",

  ARDRONE: "/Volumes/*/media_*",
  CAMERA:  "/Volumes/*/AVCHD/*/STREAM",
  STORE:   "/Users/7korobi/Movies/AVCHD",
  NAS_SRC: "/Volumes/media/Album/Videos/AVCHD",

  ENCODE:  "/Users/7korobi/Movies/HandBrake",
  NAS_JPG: "/Volumes/media/Album/Photo",
  NAS_DST: "/Volumes/media/Album/Videos/iPad",
}

handbrake_format = %w[
  /bin/HandBrakeCLI
    -f mp4 -4
    --verbose=1
    --pfr --detelecine --decomb
    --crop 0:0:0:0 
    --encopts level=4.2:ref=6:weightp=1:subq=2:rc-lookahead=10:trellis=2:8x8dct=0:bframes=5:b-adapt=2
    -e x264 -q 23 -r 60
    -N jpn -E ffac3  -6 5point1 -R Auto -B 256 -D 2.0
    -i %s
    -o %s
]

def execute_for_file(src_path, format, match = "/**/*.*")
  cmds = ["mkdir -p #{src_path.inspect}"]

  Dir.glob(src_path + match).each do |src_fname|
    target = yield(src_fname)
    path = target.split("/")
    path.pop
    cmds.push "mkdir -p #{path.join("/").inspect}"
    cmds.push format % [src_fname.inspect, target.inspect]
  end

  cmds.uniq.each do |cmd|
    puts cmd
    system cmd
  end
end

COMMENTS = {}
def comment(name, item)
  datestamp = item.mtime.strftime("%Y-%m-%d")
  COMMENTS[datestamp] ||= begin
    since_birth = item.mtime - Time.new(2013,6,24,5)
    time_of_day = 1 * 24*60*60

    puts "### input comment at #{datestamp} ( = #{(since_birth/time_of_day).ceil} days.) ###"
    `open "#{name}"`
    gets.chomp
  end
end

dirs = []
dirs += `cd #{PATH[:IPAD_CP]} && find . -type d | grep -v AppleDouble`.split("¥n")
dirs += `cd #{PATH[:QTIME  ]} && find . -type d | grep -v AppleDouble`.split("¥n")
dirs += `cd #{PATH[:STORE  ]} && find . -type d | grep -v AppleDouble`.split("¥n")
puts dirs.uniq.sort


execute_for_file(PATH[:CAM_JPG], "mv -f %s %s") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:PHOTO]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
execute_for_file(PATH[:IPAD_CP], "mv -f %s %s", "/**/*.jpg") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:PHOTO]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
execute_for_file(PATH[:IPAD_CP], "mv -f %s %s", "/**/*.JPG") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:PHOTO]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
puts "=== from : #{PATH[:CAM_JPG]}"
puts "=== from : #{PATH[:IPAD_CP]}"
puts "===   to : #{PATH[:PHOTO]}"

execute_for_file(PATH[:ARDRONE], "mv -f %s %s") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:STORE]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
execute_for_file(PATH[:CAMERA], "mv -f %s %s") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:STORE]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
puts "=== from : #{PATH[:ARDRONE]}"
puts "=== from : #{PATH[:CAMERA]}"
puts "===   to : #{PATH[:STORE]}"

execute_for_file(PATH[:IPAD_CP], "mv -f %s %s", "/**/*.mov") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:QTIME]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
execute_for_file(PATH[:IPAD_CP], "mv -f %s %s", "/**/*.MOV") do |name|
  item = File::Stat.new(name)
  timestamp = item.mtime.strftime("%Y-%m-%d.%H.%M.%S")
  ext = name.split(".")[-1]

  "#{PATH[:QTIME]}/#{comment(name, item)}/#{timestamp}_.#{ext}"
end
puts "=== from : #{PATH[:IPAD_CP]}"
puts "===   to : #{PATH[:QTIME]}"




puts "### copy to local-store release camera OK. ###"

puts "### encode movie files by HandBrakeCLI. ###"
execute_for_file(PATH[:STORE], handbrake_format.join(" ")) do |name|
  target_postfix = name.gsub(PATH[:STORE], "")
  ary = target_postfix.split("/")

  if ary.size > 2
    ary.shift
    target_postfix = "#{ary.shift}/#{ary.join("-")}"
  end

  ext = target_postfix.split(".")[-1]
  target_postfix[".#{ext}"] = ".mp4"
  "#{PATH[:ENCODE]}/#{target_postfix}"
end
execute_for_file(PATH[:QTIME], handbrake_format.join(" ")) do |name|
  target_postfix = name.gsub(PATH[:QTIME], "")
  ary = target_postfix.split("/")

  if ary.size > 2
    ary.shift
    target_postfix = "#{ary.shift}/#{ary.join("-")}"
  end

  ext = target_postfix.split(".")[-1]
  target_postfix[".#{ext}"] = ".mp4"
  "#{PATH[:ENCODE]}/#{target_postfix}"
end
puts "=== from : #{PATH[:STORE]}"
puts "=== from : #{PATH[:QTIME]}"
puts "===   to : #{PATH[:ENCODE]}"


puts "### copy to nas-strage. ###"
execute_for_file(PATH[:PHOTO], "mv -f %s %s") do |name|
  target_postfix = name.gsub(PATH[:PHOTO], "")
  "#{PATH[:NAS_JPG]}/#{target_postfix}"
end
puts "=== from : #{PATH[:PHOTO]}"
puts "===   to : #{PATH[:NAS_JPG]}"

execute_for_file(PATH[:ENCODE], "mv -f %s %s") do |name|
  target_postfix = name.gsub(PATH[:ENCODE], "")
  "#{PATH[:NAS_DST]}/#{target_postfix}"
end
puts "=== from : #{PATH[:ENCODE]}"
puts "===   to : #{PATH[:NAS_DST]}"

execute_for_file(PATH[:STORE], "mv -f %s %s") do |name|
  target_postfix = name.gsub(PATH[:STORE], "")
  "#{PATH[:NAS_SRC]}/#{target_postfix}"
end
puts "=== from : #{PATH[:STORE]}"
puts "===   to : #{PATH[:NAS_SRC]}"

execute_for_file(PATH[:QTIME], "mv -f %s %s") do |name|
  target_postfix = name.gsub(PATH[:QTIME], "")
  "#{PATH[:NAS_QT]}/#{target_postfix}"
end
puts "=== from : #{PATH[:QTIME]}"
puts "===   to : #{PATH[:NAS_QT]}"



puts "### cleanup local-store. ###"
system "rmdir -p #{PATH[:STORE]}/*/*/*"
system "rmdir -p #{PATH[:STORE]}/*/*"
system "rmdir -p #{PATH[:STORE]}/*"
system "rmdir -p #{PATH[:ENCODE]}/*/*/*"
system "rmdir -p #{PATH[:ENCODE]}/*/*"
system "rmdir -p #{PATH[:ENCODE]}/*"

