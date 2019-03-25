require 'open-uri'
require 'yaml'

$url_head = "http://www5a.biglobe.ne.jp/dinah/names/alphaNat/"

$out = "./namedb.yml"
$is_done = {}

def scan_names( leaf_key, key )
  open( $url_head + leaf_key ) do |f|
    $is_done[leaf_key] = true
    write_at = (f.last_modified.to_f * 1000 ).to_i
    body = f.read.encode("UTF-8", "Shift_JIS").scan %r|<pre>(.+)</pre>|m
    p f.base_uri

    suburls = body[0][0].scan %r|<a href=([^.]+\.htm)|
    suburls.each do |(leaf_key)|
      next if $is_done[leaf_key]
      scan_names( leaf_key, key )
    end

    body = body[0][0].gsub(/&#.[^;]+;/) do |code|
      case code[2]
      when 'x','X'
        code[3..4].to_i(16).chr("UTF-8")
      else
        p code
        code[2..4].to_i(10).chr("UTF-8")
      end
    end
    body = body.split(/\n/).map {|s| s.split(" ") }
    body.each_with_index do |ary, idx|
      if ary.size != 2
        p ary
        next
      end
      ary[0].split("／").each do | spell |
        ary[1].split("／").each do | name |
          yml = YAML.dump([{
            "write_at" => write_at,
            "spell" => spell,
            "name" => name,
            "key" => key,
            "_id" => "#{key}-#{leaf_key}.#{idx}",
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

  write_at = (f.last_modified.to_f * 1000 ).to_i 
  countrydb = {}
  countries.each do |(key, country)|
    countrydb[key] = {
    "write_at" => write_at,
    "country" => country,
    "_id" => key,
    }
  end

  File.open($out,"w") do |f|
    YAML.dump({
      "by" => $url_head,
      "country" => countrydb,
      "name" => nil,
    }, f)
  end

  countries.each do |key, _|
    scan_names( key, key )
  end

  YAML.load_file($out)
end
