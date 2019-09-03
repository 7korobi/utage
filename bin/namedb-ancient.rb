require 'open-uri'
require 'yaml'


$out = "../../giji-fire-new/yaml/work_namedb_ancient.yml"
$is_done = {}

$url_head = "http://www.efendi.jp/rq/script/languages/ancient/names/"
$country_list = [
  # ["ALLAH" , "神", "allah_names.html"],
  ["EGY" , "古アラブ", "arab_names.html"],
  ["EGY" , "古カナアン", "canaanite_names.html"],
  ["CHN" , "古中国", "chinese_names.html"],
  ["CZE" , "古クロアチア", "croatian_names.html"],
  ["CZE" , "古チェコ", "czech_names.html"],
  ["DEN" , "古デンマーク", "danish_names.html"],
  ["NED" , "古オランダ", "dutch_names.html"],
  ["USA" , "古イギリス", "english_names.html"],
  ["FIN" , "古フィンランド", "finnish_names.html"],
  ["FRA" , "古フランス", "french_names.html"],
  ["GER" , "古ドイツ", "german_names.html"],
  ["GRE" , "古ギリシャ", "greek_names.html"],
  ["ISR" , "古ヘブライ", "hebrew_names.html"],
  ["HUN" , "古ハンガリー", "hungarian_names.html"],
  ["IND" , "古インド", "indian_names.html"],
  ["ITA" , "古イタリア", "italian_names.html"],
  ["CHN" , "古韓国",  "korean_names.html"],
  ["ITA" , "古ローマ", "latin_names.html"],
  ["NOR" , "古ノルウェー", "norwegian_names.html"],
  ["IRI" , "古ペルシア", "persian_names.html"],
  ["POL" , "古ポーランド", "polish_names.html"],
  ["POR" , "古ポルトガル", "portuguese_names.html"],
  ["RUS" , "古ロシア", "russian_names.html"],
  ["ESP" , "古スペイン", "spanish_names.html"],
  ["SWE" , "古スウェーデン", "swedish_names.html"],
  ["THA" , "古タイ", "thai_names.html"],
  ["TUR" , "古トルコ", "turkish_names.html"],
]


$CODES = {
  'nbsp'   => "\u00A0",
  'lt'     => '<',
  'gt'     => '>',
  'amp'    => '&',
  'quot'   => '\"',
  'apos'   => '\'',

  'iexcl'  => '¡', #	00A1	0161	&iexcl;	逆立ち感嘆符
  'cent'   => '¢', #	00A2	0162	&cent;	セント記号
  'pound'  => '£', #	00A3	0163	&pound;	英貨ポンド記号
  'curren' => '¤', #	00A4	0164	&curren;	一般通貨記号
  'yen'    => '¥', #	00A5	0165	&yen;	円記号
  'brvbar' => '¦', #	00A6	0166	&brvbar;	縦破線
  'sent'   => '§', #	00A7	0167	&sect;	節記号
  'uml'    => '¨', #	00A8	0168	&uml;	ウムラウト
  'copy'   => '©', #	00A9	0169	&copy;	著作権記号
  'ordf'   => 'ª', #	00AA	0170	&ordf;	順序の指示（女性形）
  'laquo'  => '«', #	00AB	0171	&laquo;	左角引用符
  'not'    => '¬', #	00AC	0172	&not;	否定記号
  'shy'    => "\u00ad", #	0173	&shy;	ソフトハイフン
  'reg'    => '®', #	00AE	0174	&reg;	登録商標
  'macr'   => '¯', #	00AF	0175	&macr;	マクロン
  'deg'    => '°', #	00B0	0176	&deg;	度記号
  'plusmn' => '±', #	00B1	0177	&plusmn;	プラスマイナス記号
  'sup2'   => '²', #	00B2	0178	&sup2;	上付き数字の2、平方
  'sup3'   => '³', #	00B3	0179	&sup3;	上付き数字の3、立方
  'acute'  => '´', #	00B4	0180	&acute;	鋭アクセント
  'micro'  => 'µ', #	00B5	0181	&micro;	ミクロン記号
  'para'   => '¶', #	00B6	0182	&para;	段落記号
  'middot' => '·', #	00B7	0183	&middot;	中黒
  'cedil'  => '¸', #	00B8	0184	&cedil;	セディーユ
  'sup1'   => '¹', #	00B9	0185	&sup1;	上付き数字の1
  'ordm'   => 'º', #	00BA	0186	&ordm;	順序の指示（男性形）
  'raquo'  => '»', #	00BB	0187	&raquo;	右角引用符
  'frac14' => '¼', #	00BC	0188	&frac14;	分数1/4
  'frac12' => '½', #	00BD	0189	&frac12;	分数1/2
  'frac34' => '¾', #	00BE	0190	&frac34;	分数3/4
  'iquest' => '¿', #	00BF	0191	&iquest;	逆立ち疑問符
  'Agrave' => 'À', #	00C0	0192	&Agrave;	大文字 A（重アクセント記号付）
  'Aacute' => 'Á', #	00C1	0193	&Aacute;	大文字 A（鋭アクセント付）
  'Acirc'  => 'Â', #	00C2	0194	&Acirc;	大文字 A（曲折アクセント記号付）
  'Atilde' => 'Ã', #	00C3	0195	&Atilde;	大文字 A（ティルデ付）
  'Auml'   => 'Ä', #	00C4	0196	&Auml;	大文字 A（ウムラウト付）
  'Aring'  => 'Å', #	00C5	0197	&Aring;	大文字 A（輪付）
  'AElig'  => 'Æ', #	00C6	0198	&AElig;	大文字 AE 二重母音（合字）
  'Ccedil' => 'Ç', #	00C7	0199	&Ccedil;	大文字 C（セディーユ付）
  'Egrave' => 'È', #	00C8	0200	&Egrave;	大文字 E（重アクセント記号付）
  'Eacute' => 'É', #	00C9	0201	&Eacute;	大文字 E（鋭アクセント記号付）
  'Ecirc'  => 'Ê', #	00CA	0202	&Ecirc;	大文字 E（曲折アクセント付）
  'Euml'   => 'Ë', #	00CB	0203	&Euml;	大文字 E（ウムラウト付）
  'Igrave' => 'Ì', #	00CC	0204	&Igrave;	大文字 I（重アクセント記号付）
  'Iacute' => 'Í', #	00CD	0205	&Iacute;	大文字 I（鋭アクセント記号付）
  'Icirc'  => 'Î', #	00CE	0206	&Icirc;	大文字 I（曲折アクセント付）
  'Iuml'   => 'Ï', #	00CF	0207	&Iuml;	大文字 I（ウムラウト付）
  'ETH'    => 'Ð', #	00D0	0208	&ETH;	大文字エズ
  'Ntilde' => 'Ñ', #	00D1	0209	&Ntilde;	大文字 N（ティルデ付）
  'Ograve' => 'Ò', #	00D2	0210	&Ograve;	大文字 O（重アクセント記号付）
  'Oacute' => 'Ó', #	00D3	0211	&Oacute;	大文字 O（鋭アクセント記号付）
  'Ocirc'  => 'Ô', #	00D4	0212	&Ocirc;	大文字 O（曲折アクセント記号付）
  'Otilde' => 'Õ', #	00D5	0213	&Otilde;	大文字 O （ティルデ付）
  'Ouml'   => 'Ö', #	00D6	0214	&Ouml;	大文字 O（ウムラウト付）
  'times'  => '×', #	00D7	0215	&times;	乗算記号
  'Oslash' => 'Ø', #	00D8	0216	&Oslash;	大文字 O（スラッシュ付）
  'Ugrave' => 'Ù', #	00D9	0217	&Ugrave;	大文字 U（重アクセント記号付）
  'Uacute' => 'Ú', #	00DA	0218	&Uacute;	大文字 U（鋭アクセント記号付）
  'Ucirc'  => 'Û', #	00DB	0219	&Ucirc;	大文字 U（曲折アクセント記号付）
  'Uuml'   => 'Ü', #	00DC	0220	&Uuml;	大文字 U（ウムラウト付）
  'Yacute' => 'Ý', #	00DD	0221	&Yacute;	大文字 Y（鋭アクセント記号付）
  'THORN'  => 'Þ', #	00DE	0222	&THORN;	大文字ソーン
  'szlig'  => 'ß', #	00DF	0223	&szlig;	ドイツ語の小文字鋭 s（sz 合字）
  'agrave' => 'à', #	00E0	0224	&agrave;	小文字 a（重アクセント記号付）
  'aacute' => 'á', #	00E1	0225	&aacute;	小文字 a（鋭アクセント記号付）
  'acirc'  => 'â', #	00E2	0226	&acirc;	小文字 a（曲折アクセント記号付）
  'atilde' => 'ã', #	00E3	0227	&atilde;	小文字 a（ティルデ付）
  'auml'   => 'ä', #	00E4	0228	&auml;	小文字 a（ウムラウト付）
  'aring'  => 'å', #	00E5	0229	&aring;	小文字 a（輪付）
  'aelig'  => 'æ', #	00E6	0230	&aelig;	小文字 ae 二重母音（合字）
  'ccedil' => 'ç', #	00E7	0231	&ccedil;	小文字 c（セディーユ付）
  'egrave' => 'è', #	00E8	0232	&egrave;	小文字 e（重アクセント記号付）
  'eacute' => 'é', #	00E9	0233	&eacute;	小文字 e（鋭アクセント記号付）
  'ecirc'  => 'ê', #	00EA	0234	&ecirc;	小文字 e（曲折アクセント記号付）
  'euml'   => 'ë', #	00EB	0235	&euml;	小文字 e（ウムラウト付）
  'igrave' => 'ì', #	00EC	0236	&igrave;	小文字 i（重アクセント記号付）
  'iacute' => 'í', #	00ED	0237	&iacute;	小文字 i（鋭アクセント記号付）
  'icirc'  => 'î', #	00EE	0238	&icirc;	小文字 i（曲折アクセント記号付）
  'iuml'   => 'ï', #	00EF	0239	&iuml;	小文字 i（ウムラウト付）
  'eth'    => 'ð', #	00F0	0240	&eth;	小文字エズ
  'ntilde' => 'ñ', #	00F1	0241	&ntilde;	小文字 n（ティルデ付）
  'ograve' => 'ò', #	00F2	0242	&ograve;	小文字 o（重アクセント記号付）
  'oacute' => 'ó', #	00F3	0243	&oacute;	小文字 o（鋭アクセント記号付）
  'ocirc'  => 'ô', #	00F4	0244	&ocirc;	小文字 o（曲折アクセント記号付）
  'otilde' => 'õ', #	00F5	0245	&otilde;	小文字 o（ティルデ付）
  'ouml'   => 'ö', #	00F6	0246	&ouml;	小文字 o（ウムラウト付）
  'divide' => '÷', #	00F7	0247	&divide;	除算記号
  'oslash' => 'ø', #	00F8	0248	&oslash;	小文字 o（斜線付）
  'ugrave' => 'ù', #	00F9	0249	&ugrave;	小文字 u（重アクセント記号付）
  'uacute' => 'ú', #	00FA	0250	&uacute;	小文字 u（鋭アクセント記号付）
  'ucirc'  => 'û', #	00FB	0251	&ucirc;	小文字 u（曲折アクセント記号付）
  'uuml'   => 'ü', #	00FC	0252	&uuml;	小文字 u（ウムラウト付）
  'yacute' => 'ý', #	00FD	0253	&yacute;	小文字 y（鋭アクセント記号付）
  'thorn'  => 'þ', #	00FE	0254	&thorn;	小文字ソーン
  'yuml'   => 'ÿ', #	00FF	0255	&yuml;	小文字 y（ウムラウト付）
}


def decodeHTML(text)
  text
  .gsub('<sup>a</sup>','ª')
  .gsub('<sup>e</sup>','ᵉ')
  .gsub('<sup>o</sup>','ᵒ')
  .gsub('Benoicirc;t','Benoît')
  .gsub('&oumul;','ö')
  .gsub(/&[^;]+;/) do |code|
    if '#' == code[1]
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
        code[2..].to_i(10).chr("UTF-8")
      end
    else
      $CODES[code[1..-2]] || raise(code)
    end
  end
end

def scan_names( leaf_key, key, mark )
  open( $url_head + leaf_key ) do |f|
    p f.base_uri
    $is_done[leaf_key] = f.last_modified

    bodys = f.read.encode("UTF-8", "UTF-8").scan %r|<td valign="top">\s+<p>(.+?)</p>\s+</td>|m
    bodys.each_with_index do |body, idx|
      body = decodeHTML body[0]
      body = body.split(%r| *<br /> *\n*|).map {|s| s.strip.split(/[ \(\)（）]+/) }
      last_comment = []
      body.each do |(name, spell, *comment)|
        if " >" == name
          name  = spell
          spell = comment[0]
        else
          last_comment = comment
        end
        if ! name && ! spell
          p name, spell, comment
          next
        end
        yml = YAML.dump([{
          "spell" => spell,
          "name" => name,
          "side" => ["男", "女", "姓"][idx],
          "mark" => mark,
          "comment" => last_comment.join(" "),
          "key" => key,
        }])
        File.open($out, "a") do |f|
          f.write yml[4..]
        end
      end
    end
  end
end

File.open($out,"w") do |f|
  YAML.dump({
    "by" => "http://www.efendi.jp/rq/indices/languages/ancient/names/index.html",
    "name" => nil,
  }, f)
end

$country_list.each do |(key, mark, leaf_key)|
  scan_names( leaf_key, key, mark )
end

yml = YAML.dump({
  "timestamp" => $is_done,
})
File.open($out,"a") do |f|
  f.write yml[4..]
end

YAML.load_file($out)
