require 'open-uri'
require 'yaml'

$url_head = "http://www5a.biglobe.ne.jp/dinah/names/alphaNat/"

$out = "../../giji-fire-new/yaml/work_namedb.yml"
$is_done = {}

def scan_names( leaf_key, key )
  open( $url_head + leaf_key ) do |f|
    body = f.read.encode("UTF-8", "Shift_JIS").scan %r|<pre>(.+)</pre>|m
    p f.base_uri
    $is_done[leaf_key] = f.last_modified

    suburls = body[0][0].scan %r|<a href=([^.]+\.htm)|
    suburls.each do |(leaf_key)|
      next if $is_done[leaf_key]
      scan_names( leaf_key, key )
    end
    body = body[0][0].gsub(/&#[^;]+;/) do |code|
      case code[2]
      when 'x','X'
        val = code[3..].to_i(16)
        case val
        when 0x80..0x9f
          val.chr("cp1252").encode("UTF-8")
        else
          val.chr("UTF-8")
        end
      else
        p code
        code[2..].to_i(10).chr("UTF-8")
      end
    end
    body = body.split(/\n/).map {|s| s.split(" ") }
    body.each do |ary|
      if ary.size != 2
        p ary
        next
      end
      ary[0].split("／").each do | spell |
        ary[1].split("／").each do | name |
          yml = YAML.dump([{
            "spell" => spell,
            "name" => name,
            "key" => key[0..-5],
          }])
          File.open($out, "a") do |f|
            f.write yml[4..]
          end
        end
      end
    end
  end
end

open( $url_head + "alnatix.htm") do |f|
  country_list = f.read.encode("UTF-8", "Shift_JIS").scan %r|<a href=([^.]+\.htm) target=DATA>([^<]+)</a><br>|
  countries = country_list.each_with_object({}) do |(key, country), h|
    h[key] =
      if h[key]
        h[key] + [country]
      else
        [country]
      end
  end

  countrydb = {}
  countries.each do |(key, country)|
    _id = key[0..-5]
    countrydb[_id] = {
    "country" => country,
    "_id" => _id,
    }
  end

  File.open($out,"w") do |f|
    YAML.dump({
      "by" => $url_head,
      "name" => nil,
    }, f)
  end

  countries.each do |key, _|
    scan_names( key, key )
  end

  yml = YAML.dump({
    "country" => countrydb,
    "timestamp" => $is_done,
  })
  File.open($out,"a") do |f|
    f.write yml[4..]
  end

  YAML.load_file($out)
end