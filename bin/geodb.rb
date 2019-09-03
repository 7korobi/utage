require 'open-uri'
require "net/http"
require 'zip'
require 'yaml'
require 'json'

FNAME_GEOCODE_ZIP = "/tmp/geolist.zip"
FNAME_ZIPCODE_ZIP = "/tmp/zipcode.zip"

FNAME_GEOCODE = "../data/geolist_utf8.csv"
FNAME_ZIPCODE = "../data/zipcode_sjis.csv"


FNAME_SNAP_HD     = "../../giji-fire-new/yaml/work_geo_"
FNAME_OUTPUT_YAML = "../../giji-fire-new/yaml/work_geo.yml"

POSTS_JIS_ZIP = {}
POSTS_ZIP = {}
POSTS_JIS = {}

GEOS = []
NAME_GEOS = {}

ETCS = {}
NAMES = {}
LABELS = {}

DIC = {}
TO_PREFECTURE = {}

PAST_DIC = YAML.load_file(FNAME_SNAP_HD + "dic.yml")

def find_header(*args)
  ( 1 .. args.map(&:size).min ).reverse_each do |idx|
    return args[0][0..idx] if 1 == args.map {|arg| arg[0..idx] }.uniq.size 
  end
  nil
end

def cut(src, r, sep, gap, safe )
  saved = src[safe]
  src.gsub!(safe, "@@@")
  hit = src[r]
  if hit
    src[r] = ""
    list = hit.tr(sep,"").split(gap).map {|s| "#{sep[0]}#{s}#{sep[1]}" }
    if saved
      list.each do |s|
        s.gsub!("@@@", saved) 
      end
    end
  else
    list = []
    if saved
      src.gsub!("@@@", saved) 
    end
  end
  list.uniq.select {|s| ! [nil,""].member? s }
end

def to_etc(*ary)
  ary.uniq.select {|s| !([nil, ""].member? s) }
end

def label_reduce(root, checker = {}, dest = {})
  root.each do |key, item|
    dest[key] = LABELS[key]
    check = checker[LABELS[key]]
    if 0 == item || 0 == item.size
      check = checker[LABELS[key]] = 0
    else
      unless Hash === check
        check = checker[LABELS[key]] = {}
      end
      label_reduce(item, check, dest)
    end
  end
  dest
end

def name_reduce!(root)
  news = {}
  root.each do |key, item|
    next if 0 == item
    next if 0 == item.size
    if 1 == item.size
      new_key = item.keys[0]
      new_val = item.values[0]
      news[new_key] = new_val
      LABELS[new_key] = LABELS[key]
      root.delete(key)
    else
      item.replace name_reduce!(item).sort.to_h
    end
  end
  news.each do |key, val|
    root[key] = val
  end
  if 0 < news.size
    name_reduce!(root)
  end
  root
end

def label_set(prefecture, key, label)
  (LABELS[key], unit) = label.split(/([都府県市郡区村町]）?$)/)
  return if unit == label
  return unless unit
  label.tr!("()（）","")
  unit.tr!("()（）","")
  DIC[prefecture] ||= {}
  DIC[prefecture][unit] ||= {}
  DIC[prefecture][unit][label] = 0
end

def name_set(names, *dirty)
  (*args, tail) = dirty.select {|s| s != "" }
  head = ""
  args.each_with_index do |arg, idx|
    label = arg
    head = arg = head + arg
    if [nil, 0].member? names[arg]
      names[arg] = {}
    end
    names = names[arg]
    label_set(dirty[0], arg, label)
  end
  if tail.start_with? head
    full = tail
  else
    if ["#{head[-1]}庁","#{head[-1]}役所"].member? tail
      full = head + tail[1..]
    else
      full = head + tail
    end
  end
  names[full] ||= 0
  if full[/#{tail}.#{tail}$/]
    LABELS[full] = tail
  else
    label_set(dirty[0], full, tail)
  end
  full
end

# katakana to hiragana for utf-8
def to_hiragana(src)
  src.codepoints.collect do |cp|
    if ( 0x30a1 .. 0x30f6 ) === cp
      (cp - 0x60).chr("UTF-8")
    else
      cp.chr("UTF-8")
    end
  end.join("")
end

# hiragana to katakana for utf-8
def to_katakana(src)
  src.codepoints.collect do |cp|
    if ( 0x3041 .. 0x3096 ) === cp
      (cp + 0x60).chr("UTF-8")
    else
      cp.chr("UTF-8")
    end
  end.join("")
end


open('https://www.post.japanpost.jp/zipcode/dl/oogaki/zip/ken_all.zip') do |fr|
  File.open(FNAME_ZIPCODE_ZIP,'w') do |fw|
    fw.write fr.read
  end
end

Zip::File.open(FNAME_ZIPCODE_ZIP) do |zip|
  zip.each do |entry|
    if "KEN_ALL.CSV" == entry.name
      zip.extract(entry, FNAME_ZIPCODE) { true }
    end
  end
end

=begin
uri = URI.parse("http://www.amano-tec.com/data/download.php")
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Post.new(uri.path)
req.set_form_data({ name: "", email: "", org: "", usage: "", mail_set: 'confirm_submit', filenumber: '3', x: '78', y: '12', httpReferer: 'http://www.amano-tec.com/data/localgovernments.html' })
req.initialize_http_header({
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
  "Accept-Encoding" => "gzip, deflate",
  "Accept-Language" => "ja,en-US;q=0.9,en;q=0.8",
  "Cache-Control" => "max-age=0",
  "Connection" => "keep-alive",
  "Cookie" =>  "_ga=GA1.2.1709699922.1566976834; _gid=GA1.2.889992052.1566976834; i18next=ja; _gat=1",
  "Origin" => "http://www.amano-tec.com",
  "Referer" => "http://www.amano-tec.com/data/download.php",
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36",
})
res = http.request(req)
File.open(FNAME_GEOCODE_ZIP,'w') do |fw|
  fw.write res.body
end

Zip::File.open(FNAME_GEOCODE_ZIP) do |zip|
  zip.each do |entry|
    if "h3010puboffice_utf8.csv" == entry.name
      zip.extract(entry, FNAME_GEOCODE) { true }
    end
  end
end
=end

p "...ZIPCODE scan"
open(FNAME_ZIPCODE) do |f|
  f.read.encode("UTF-8","Shift_JIS").split("\n").each do |line|
    (jiscode, zipcode5, zipcode, ruby1, ruby2, ruby3, prefecture, city, town, is_duplicate_town, is_duplicate_won, has_town_code, has_multi_won, is_news, change_code ) = line.split(/"?,"?/)
    jiszipcode = jiscode + zipcode
    if old = POSTS_JIS_ZIP[jiszipcode]
      if old[4]["（"] && ! old[4]["）"]
        town.gsub!("その他）", "）")
        ruby3.gsub!("ｿﾉﾀ\)", ")")
        old[4] += town
        old[8] += ruby3
        old[5] = cut(old[4],  /（.*）/,"（）","、", /「.+を除く」/)
        old[9] = cut(old[8], /\(.*\)/,"()","､", /<.+ｦﾉｿﾞｸ>/)
      elsif m = town.match(/^#{old[4]}(（.+）)/)
          mr = ruby3.match(/^#{old[8]}(\(.+\))/)
          old[5] = [*old[5],m[1]].uniq
          old[9] = [*old[9],mr[1]].uniq
      elsif hd = find_header(town, old[4])
        if rubyhd = find_header(ruby3, old[8])
          old[5] = to_etc *[old[4], *old[5], town].map {|s| s.gsub(hd, "") }
          old[4] = hd
          old[9] = to_etc *[old[8], *old[9], ruby3].map {|s| s.gsub(rubyhd, "") }
          old[8] = rubyhd
        else
          p [[old[3], old[4], old[8]],[city, town, ruby3]]
        end
      else
        old[5] = to_etc old[4], *old[5], town
        old[4] = ""
        old[9] = to_etc old[8], *old[9], ruby3
        old[8] = ""
      end
      next
    end
    if /以下に掲載がない場合|の次に番地がくる場合$/ === town
      town = ruby3 = ""
    end

    town.gsub!("その他）", "）")
    ruby3.gsub!("ｿﾉﾀ\)", ")")
    etc   = cut(town,  /（.*）/,"（）","、", /「.+を除く」/)
    ruby4 = cut(ruby3, /\(.*\)/,"()","､", /<.+ｦﾉｿﾞｸ>/)
    POSTS_JIS_ZIP[jiszipcode] = POSTS_ZIP[zipcode] = POSTS_JIS[jiscode] = [zipcode, jiscode, prefecture, city, town, etc, ruby1, ruby2, ruby3, ruby4]
    TO_PREFECTURE[city] = TO_PREFECTURE[prefecture] ||= [prefecture, ruby1]
  end
end

p "...ZIPCODE structure"
POSTS_JIS_ZIP.each do |code, data|
  (zipcode, jiscode, prefecture, city, town, etc, ruby1, ruby2, ruby3, ruby4) = data
  divisions = "村町市島郡区"
  dic = divisions.each_char.to_a.map do |c|
    PAST_DIC.dig(prefecture, c)&.keys
  end.compact
  gap = "[#{divisions}）]"
  name = ""
  if 0 < etc.size
    etc.each do |etc_item|
      name = name_set(
        NAMES,
        prefecture,
        *city.split(/(#{dic.join("|")}|.+?#{gap}(?!#{gap}))/),
        *town.split(/(.+?[町村](?!#{gap}))/),
        etc_item
      )
    end
    ETCS[name] = etc 
  else
    name = name_set(
      NAMES,
      prefecture,
      *city.split(/(#{dic.join("|")}|.+?#{gap}(?!#{gap}))/),
      *town.split(/(.+?[町村](?!#{gap}))/)
    )
  end
end

p "...GEOCODE scan"
open(FNAME_GEOCODE) do |f|
  f.read.encode("UTF-8","UTF-8").split("\n").each do |line|
    ( jiscode, label, ruby, building, zipcode, address, tel, source, lat, lon, note ) = line.split("\t")
    next if 'jiscode' == jiscode
    lat = lat.to_f
    lon = lon.to_f
    jiscode = jiscode.rjust(5,"0")
    zipcode = zipcode.tr("-",'')
    post = POSTS_ZIP[zipcode] || POSTS_JIS[jiscode]
    if post
      (_zipcode, _jiscode, prefecture, city, town, etc, ruby1, ruby2, ruby3, ruby4) = post
      divisions = "村町市島郡区"
      dic = divisions.each_char.to_a.map do |c|
        PAST_DIC.dig(prefecture, c)&.keys
      end.compact
      gap = "[#{divisions}）]"
      name = name_set(
        NAME_GEOS,
        prefecture,
        *city.split(/(#{dic.join("|")}|.+?#{gap}(?!#{gap}))/),
        *town.split(/(.+?[町村](?!#{gap}))/)
      )
      ETCS[name] = etc if 0 < etc.size
      kata = [ruby1,ruby2,ruby3].join("").unicode_normalize(:nfkc)
      hira = to_hiragana(kata)
    else
      label_key = TO_PREFECTURE.keys.find {|s| s.start_with? label }
      (prefecture, ruby1) = TO_PREFECTURE[label_key]

      if label == prefecture
        # 都道府県庁の場合
        hira = ruby + "ちょう"
        name = name_set(
          NAME_GEOS,
          prefecture,
          building[-2..]
        )
      else
        # 市役所の場合
        ruby1 = ruby1.unicode_normalize(:nfkc)
        ruby1 = to_hiragana(ruby1)
        hira = [ruby1, ruby].join("")
        if building["市役所"]
          name = name_set(
            NAME_GEOS,
            prefecture,
            building.gsub(/役所$/, ""),
            "市役所"
          )
        else
          name = name_set(
            NAME_GEOS,
            prefecture,
            building,
          )
        end
      end
      kata = to_katakana(hira)
    end
    GEOS.push({
      "_id" => jiscode,
      "zip" => zipcode,
      "on" => [lat, lon],
      "name" => name,
      "label" => label,
      "hira" => hira,
      "kata" => kata,
      "tel" => tel,
      "address" => address,
    })
  end
end

CHECK_GEOS = {}
geo = {
  "zips" => GEOS,
  "names" => name_reduce!(NAME_GEOS),
  "labels" => label_reduce(NAME_GEOS, CHECK_GEOS).sort.to_h,
}

CHECKS = {}

File.open(FNAME_OUTPUT_YAML,"w") do |f|
  f.write YAML.dump geo
end

DIC.each do |key, dic|
  dic.each do |k, d|
    d.replace d.sort.reverse.to_h
  end
  dic.replace dic.sort.to_h
end
File.open(FNAME_SNAP_HD + "dic.yml","w") do |f|
  f.write YAML.dump DIC
end
File.open(FNAME_SNAP_HD + "etc.yml","w") do |f|
  f.write YAML.dump ETCS
end
File.open(FNAME_SNAP_HD + "name.yml","w") do |f|
  f.write YAML.dump name_reduce!(NAMES)
end
File.open(FNAME_SNAP_HD + "label.yml","w") do |f|
  f.write YAML.dump label_reduce(NAMES, CHECKS).sort.to_h
end


# data structure check.
YAML.load_file(FNAME_OUTPUT_YAML)
YAML.load_file(FNAME_SNAP_HD + "name.yml")
YAML.load_file(FNAME_SNAP_HD + "label.yml")
YAML.load_file(FNAME_SNAP_HD + "etc.yml")
YAML.load_file(FNAME_SNAP_HD + "dic.yml")
