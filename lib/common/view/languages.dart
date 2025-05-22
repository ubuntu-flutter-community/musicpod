class SimpleLanguage {
  SimpleLanguage(this.isoCode, this.name);

  final String name;
  final String isoCode;

  SimpleLanguage.fromMap(Map<String, String> map)
    : name = map['name']!,
      isoCode = map['isoCode']!;

  /// Returns the Language matching the given ISO code from the standard list.
  factory SimpleLanguage.fromIsoCode(String isoCode) =>
      Languages.defaultLanguages.firstWhere((l) => l.isoCode == isoCode);

  @override
  bool operator ==(other) =>
      other is SimpleLanguage && name == other.name && isoCode == other.isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}

class Languages {
  static SimpleLanguage get abkhazian => SimpleLanguage('ab', 'Abkhazian');
  static SimpleLanguage get afar => SimpleLanguage('aa', 'Afar');
  static SimpleLanguage get afrikaans => SimpleLanguage('af', 'Afrikaans');
  static SimpleLanguage get akan => SimpleLanguage('ak', 'Akan');
  static SimpleLanguage get albanian => SimpleLanguage('sq', 'Albanian');
  static SimpleLanguage get amharic => SimpleLanguage('am', 'Amharic');
  static SimpleLanguage get arabic => SimpleLanguage('ar', 'Arabic');
  static SimpleLanguage get aragonese => SimpleLanguage('an', 'Aragonese');
  static SimpleLanguage get armenian => SimpleLanguage('hy', 'Armenian');
  static SimpleLanguage get assamese => SimpleLanguage('as', 'Assamese');
  static SimpleLanguage get avaric => SimpleLanguage('av', 'Avaric');
  static SimpleLanguage get avestan => SimpleLanguage('ae', 'Avestan');
  static SimpleLanguage get aymara => SimpleLanguage('ay', 'Aymara');
  static SimpleLanguage get azerbaijani => SimpleLanguage('az', 'Azerbaijani');
  static SimpleLanguage get bambara => SimpleLanguage('bm', 'Bambara');
  static SimpleLanguage get bashkir => SimpleLanguage('ba', 'Bashkir');
  static SimpleLanguage get basque => SimpleLanguage('eu', 'Basque');
  static SimpleLanguage get belarusian => SimpleLanguage('be', 'Belarusian');
  static SimpleLanguage get bengali => SimpleLanguage('bn', 'Bengali');
  static SimpleLanguage get bihariLanguages =>
      SimpleLanguage('bh', 'Bihari Languages');
  static SimpleLanguage get bislama => SimpleLanguage('bi', 'Bislama');
  static SimpleLanguage get bosnian => SimpleLanguage('bs', 'Bosnian');
  static SimpleLanguage get breton => SimpleLanguage('br', 'Breton');
  static SimpleLanguage get bulgarian => SimpleLanguage('bg', 'Bulgarian');
  static SimpleLanguage get burmese => SimpleLanguage('my', 'Burmese');
  static SimpleLanguage get catalan => SimpleLanguage('ca', 'Catalan');
  static SimpleLanguage get centralKhmer =>
      SimpleLanguage('km', 'Central Khmer');
  static SimpleLanguage get chamorro => SimpleLanguage('ch', 'Chamorro');
  static SimpleLanguage get chechen => SimpleLanguage('ce', 'Chechen');
  static SimpleLanguage get chewaNyanja =>
      SimpleLanguage('ny', 'Chewa (Nyanja)');

  static SimpleLanguage get cantonese => SimpleLanguage('yue', 'Cantonese');
  static SimpleLanguage get chinese => SimpleLanguage('zh-CN', 'Chinese');

  static SimpleLanguage get churchSlavonic =>
      SimpleLanguage('cu', 'Church Slavonic');
  static SimpleLanguage get chuvash => SimpleLanguage('cv', 'Chuvash');
  static SimpleLanguage get cornish => SimpleLanguage('kw', 'Cornish');
  static SimpleLanguage get corsican => SimpleLanguage('co', 'Corsican');
  static SimpleLanguage get cree => SimpleLanguage('cr', 'Cree');
  static SimpleLanguage get croatian => SimpleLanguage('hr', 'Croatian');
  static SimpleLanguage get czech => SimpleLanguage('cs', 'Czech');
  static SimpleLanguage get danish => SimpleLanguage('da', 'Danish');
  static SimpleLanguage get dhivehi => SimpleLanguage('dv', 'Dhivehi');
  static SimpleLanguage get dutch => SimpleLanguage('nl', 'Dutch');
  static SimpleLanguage get dzongkha => SimpleLanguage('dz', 'Dzongkha');
  static SimpleLanguage get english => SimpleLanguage('en', 'English');
  static SimpleLanguage get esperanto => SimpleLanguage('eo', 'Esperanto');
  static SimpleLanguage get estonian => SimpleLanguage('et', 'Estonian');
  static SimpleLanguage get ewe => SimpleLanguage('ee', 'Ewe');
  static SimpleLanguage get faroese => SimpleLanguage('fo', 'Faroese');
  static SimpleLanguage get fijian => SimpleLanguage('fj', 'Fijian');
  static SimpleLanguage get finnish => SimpleLanguage('fi', 'Finnish');
  static SimpleLanguage get french => SimpleLanguage('fr', 'French');
  static SimpleLanguage get fulah => SimpleLanguage('ff', 'Fulah');
  static SimpleLanguage get gaelic => SimpleLanguage('gd', 'Gaelic');
  static SimpleLanguage get galician => SimpleLanguage('gl', 'Galician');
  static SimpleLanguage get ganda => SimpleLanguage('lg', 'Ganda');
  static SimpleLanguage get georgian => SimpleLanguage('ka', 'Georgian');
  static SimpleLanguage get german => SimpleLanguage('de', 'German');
  static SimpleLanguage get greek => SimpleLanguage('el', 'Greek');
  static SimpleLanguage get guarani => SimpleLanguage('gn', 'Guarani');
  static SimpleLanguage get gujarati => SimpleLanguage('gu', 'Gujarati');
  static SimpleLanguage get haitian => SimpleLanguage('ht', 'Haitian');
  static SimpleLanguage get hausa => SimpleLanguage('ha', 'Hausa');
  static SimpleLanguage get hebrew => SimpleLanguage('he', 'Hebrew');
  static SimpleLanguage get herero => SimpleLanguage('hz', 'Herero');
  static SimpleLanguage get hindi => SimpleLanguage('hi', 'Hindi');
  static SimpleLanguage get hiriMotu => SimpleLanguage('ho', 'Hiri Motu');
  static SimpleLanguage get hungarian => SimpleLanguage('hu', 'Hungarian');
  static SimpleLanguage get icelandic => SimpleLanguage('is', 'Icelandic');
  static SimpleLanguage get ido => SimpleLanguage('io', 'Ido');
  static SimpleLanguage get igbo => SimpleLanguage('ig', 'Igbo');
  static SimpleLanguage get indonesian => SimpleLanguage('id', 'Indonesian');
  static SimpleLanguage get interlingua => SimpleLanguage('ia', 'Interlingua');
  static SimpleLanguage get interlingue => SimpleLanguage('ie', 'Interlingue');
  static SimpleLanguage get inuktitut => SimpleLanguage('iu', 'Inuktitut');
  static SimpleLanguage get inupiaq => SimpleLanguage('ik', 'Inupiaq');
  static SimpleLanguage get irish => SimpleLanguage('ga', 'Irish');
  static SimpleLanguage get italian => SimpleLanguage('it', 'Italian');
  static SimpleLanguage get japanese => SimpleLanguage('ja', 'Japanese');
  static SimpleLanguage get javanese => SimpleLanguage('jv', 'Javanese');
  static SimpleLanguage get kalaallisut => SimpleLanguage('kl', 'Kalaallisut');
  static SimpleLanguage get kannada => SimpleLanguage('kn', 'Kannada');
  static SimpleLanguage get kanuri => SimpleLanguage('kr', 'Kanuri');
  static SimpleLanguage get kashmiri => SimpleLanguage('ks', 'Kashmiri');
  static SimpleLanguage get kazakh => SimpleLanguage('kk', 'Kazakh');
  static SimpleLanguage get kikuyu => SimpleLanguage('ki', 'Kikuyu');
  static SimpleLanguage get kinyarwanda => SimpleLanguage('rw', 'Kinyarwanda');
  static SimpleLanguage get kirghiz => SimpleLanguage('ky', 'Kirghiz');
  static SimpleLanguage get komi => SimpleLanguage('kv', 'Komi');
  static SimpleLanguage get kongo => SimpleLanguage('kg', 'Kongo');
  static SimpleLanguage get korean => SimpleLanguage('ko', 'Korean');
  static SimpleLanguage get kuanyama => SimpleLanguage('kj', 'Kuanyama');
  static SimpleLanguage get kurdish => SimpleLanguage('ku', 'Kurdish');
  static SimpleLanguage get lao => SimpleLanguage('lo', 'Lao');
  static SimpleLanguage get latin => SimpleLanguage('la', 'Latin');
  static SimpleLanguage get latvian => SimpleLanguage('lv', 'Latvian');
  static SimpleLanguage get limburgan => SimpleLanguage('li', 'Limburgan');
  static SimpleLanguage get lingala => SimpleLanguage('ln', 'Lingala');
  static SimpleLanguage get lithuanian => SimpleLanguage('lt', 'Lithuanian');
  static SimpleLanguage get lubaKatanga => SimpleLanguage('lu', 'Luba-Katanga');
  static SimpleLanguage get luxembourgish =>
      SimpleLanguage('lb', 'Luxembourgish');
  static SimpleLanguage get macedonian => SimpleLanguage('mk', 'Macedonian');
  static SimpleLanguage get malagasy => SimpleLanguage('mg', 'Malagasy');
  static SimpleLanguage get malay => SimpleLanguage('ms', 'Malay');
  static SimpleLanguage get malayalam => SimpleLanguage('ml', 'Malayalam');
  static SimpleLanguage get maltese => SimpleLanguage('mt', 'Maltese');
  static SimpleLanguage get manx => SimpleLanguage('gv', 'Manx');
  static SimpleLanguage get maori => SimpleLanguage('mi', 'Maori');
  static SimpleLanguage get marathi => SimpleLanguage('mr', 'Marathi');
  static SimpleLanguage get marshallese => SimpleLanguage('mh', 'Marshallese');
  static SimpleLanguage get mongolian => SimpleLanguage('mn', 'Mongolian');
  static SimpleLanguage get nauru => SimpleLanguage('na', 'Nauru');
  static SimpleLanguage get navajo => SimpleLanguage('nv', 'Navajo');
  static SimpleLanguage get ndebeleNorth =>
      SimpleLanguage('nd', 'Ndebele, North');
  static SimpleLanguage get ndebeleSouth =>
      SimpleLanguage('nr', 'Ndebele, South');
  static SimpleLanguage get ndonga => SimpleLanguage('ng', 'Ndonga');
  static SimpleLanguage get nepali => SimpleLanguage('ne', 'Nepali');
  static SimpleLanguage get northernSami =>
      SimpleLanguage('se', 'Northern Sami');
  static SimpleLanguage get norwegian => SimpleLanguage('no', 'Norwegian');
  static SimpleLanguage get norwegianNynorsk =>
      SimpleLanguage('nn', 'Norwegian Nynorsk');
  static SimpleLanguage get occitan => SimpleLanguage('oc', 'Occitan');
  static SimpleLanguage get ojibwa => SimpleLanguage('oj', 'Ojibwa');
  static SimpleLanguage get oriya => SimpleLanguage('or', 'Oriya');
  static SimpleLanguage get oromo => SimpleLanguage('om', 'Oromo');
  static SimpleLanguage get ossetian => SimpleLanguage('os', 'Ossetian');
  static SimpleLanguage get pali => SimpleLanguage('pi', 'Pali');
  static SimpleLanguage get panjabi => SimpleLanguage('pa', 'Panjabi');
  static SimpleLanguage get persian => SimpleLanguage('fa', 'Persian');
  static SimpleLanguage get polish => SimpleLanguage('pl', 'Polish');
  static SimpleLanguage get portuguese => SimpleLanguage('pt', 'Portuguese');
  static SimpleLanguage get pushto => SimpleLanguage('ps', 'Pushto');
  static SimpleLanguage get quechua => SimpleLanguage('qu', 'Quechua');
  static SimpleLanguage get romanian => SimpleLanguage('ro', 'Romanian');
  static SimpleLanguage get romansh => SimpleLanguage('rm', 'Romansh');
  static SimpleLanguage get rundi => SimpleLanguage('rn', 'Rundi');
  static SimpleLanguage get russian => SimpleLanguage('ru', 'Russian');
  static SimpleLanguage get samoan => SimpleLanguage('sm', 'Samoan');
  static SimpleLanguage get sango => SimpleLanguage('sg', 'Sango');
  static SimpleLanguage get sanskrit => SimpleLanguage('sa', 'Sanskrit');
  static SimpleLanguage get sardinian => SimpleLanguage('sc', 'Sardinian');
  static SimpleLanguage get serbian => SimpleLanguage('sr', 'Serbian');
  static SimpleLanguage get shona => SimpleLanguage('sn', 'Shona');
  static SimpleLanguage get sichuanYi => SimpleLanguage('ii', 'Sichuan Yi');
  static SimpleLanguage get sindhi => SimpleLanguage('sd', 'Sindhi');
  static SimpleLanguage get sinhala => SimpleLanguage('si', 'Sinhala');
  static SimpleLanguage get slovak => SimpleLanguage('sk', 'Slovak');
  static SimpleLanguage get slovenian => SimpleLanguage('sl', 'Slovenian');
  static SimpleLanguage get somali => SimpleLanguage('so', 'Somali');
  static SimpleLanguage get sothoSouthern =>
      SimpleLanguage('st', 'Sotho, Southern');
  static SimpleLanguage get spanish => SimpleLanguage('es', 'Spanish');
  static SimpleLanguage get sundanese => SimpleLanguage('su', 'Sundanese');
  static SimpleLanguage get swahili => SimpleLanguage('sw', 'Swahili');
  static SimpleLanguage get swati => SimpleLanguage('ss', 'Swati');
  static SimpleLanguage get swedish => SimpleLanguage('sv', 'Swedish');
  static SimpleLanguage get tagalog => SimpleLanguage('tl', 'Tagalog');
  static SimpleLanguage get tahitian => SimpleLanguage('ty', 'Tahitian');
  static SimpleLanguage get tajik => SimpleLanguage('tg', 'Tajik');
  static SimpleLanguage get tamil => SimpleLanguage('ta', 'Tamil');
  static SimpleLanguage get tatar => SimpleLanguage('tt', 'Tatar');
  static SimpleLanguage get telugu => SimpleLanguage('te', 'Telugu');
  static SimpleLanguage get thai => SimpleLanguage('th', 'Thai');
  static SimpleLanguage get tibetan => SimpleLanguage('bo', 'Tibetan');
  static SimpleLanguage get tigrinya => SimpleLanguage('ti', 'Tigrinya');
  static SimpleLanguage get tongaTongaIslands =>
      SimpleLanguage('to', 'Tonga (Tonga Islands)');
  static SimpleLanguage get tsonga => SimpleLanguage('ts', 'Tsonga');
  static SimpleLanguage get tswana => SimpleLanguage('tn', 'Tswana');
  static SimpleLanguage get turkish => SimpleLanguage('tr', 'Turkish');
  static SimpleLanguage get turkmen => SimpleLanguage('tk', 'Turkmen');
  static SimpleLanguage get twi => SimpleLanguage('tw', 'Twi');
  static SimpleLanguage get uighur => SimpleLanguage('ug', 'Uighur');
  static SimpleLanguage get ukrainian => SimpleLanguage('uk', 'Ukrainian');
  static SimpleLanguage get urdu => SimpleLanguage('ur', 'Urdu');
  static SimpleLanguage get uzbek => SimpleLanguage('uz', 'Uzbek');
  static SimpleLanguage get venda => SimpleLanguage('ve', 'Venda');
  static SimpleLanguage get vietnamese => SimpleLanguage('vi', 'Vietnamese');
  static SimpleLanguage get volapuk => SimpleLanguage('vo', 'Volapük');
  static SimpleLanguage get walloon => SimpleLanguage('wa', 'Walloon');
  static SimpleLanguage get welsh => SimpleLanguage('cy', 'Welsh');
  static SimpleLanguage get westernFrisian =>
      SimpleLanguage('fy', 'Western Frisian');
  static SimpleLanguage get wolof => SimpleLanguage('wo', 'Wolof');
  static SimpleLanguage get xhosa => SimpleLanguage('xh', 'Xhosa');
  static SimpleLanguage get yiddish => SimpleLanguage('yi', 'Yiddish');
  static SimpleLanguage get yoruba => SimpleLanguage('yo', 'Yoruba');
  static SimpleLanguage get zhuang => SimpleLanguage('za', 'Zhuang');
  static SimpleLanguage get zulu => SimpleLanguage('zu', 'Zulu');

  static List<SimpleLanguage> defaultLanguages = [
    Languages.abkhazian,
    Languages.afar,
    Languages.afrikaans,
    Languages.akan,
    Languages.albanian,
    Languages.amharic,
    Languages.arabic,
    Languages.aragonese,
    Languages.armenian,
    Languages.assamese,
    Languages.avaric,
    Languages.avestan,
    Languages.aymara,
    Languages.azerbaijani,
    Languages.bambara,
    Languages.bashkir,
    Languages.basque,
    Languages.belarusian,
    Languages.bengali,
    Languages.bihariLanguages,
    Languages.bislama,
    Languages.bosnian,
    Languages.breton,
    Languages.bulgarian,
    Languages.burmese,
    Languages.catalan,
    Languages.centralKhmer,
    Languages.chamorro,
    Languages.chechen,
    Languages.chewaNyanja,
    Languages.cantonese,
    Languages.chinese,
    Languages.churchSlavonic,
    Languages.chuvash,
    Languages.cornish,
    Languages.corsican,
    Languages.cree,
    Languages.croatian,
    Languages.czech,
    Languages.danish,
    Languages.dhivehi,
    Languages.dutch,
    Languages.dzongkha,
    Languages.english,
    Languages.esperanto,
    Languages.estonian,
    Languages.ewe,
    Languages.faroese,
    Languages.fijian,
    Languages.finnish,
    Languages.french,
    Languages.fulah,
    Languages.gaelic,
    Languages.galician,
    Languages.ganda,
    Languages.georgian,
    Languages.german,
    Languages.greek,
    Languages.guarani,
    Languages.gujarati,
    Languages.haitian,
    Languages.hausa,
    Languages.hebrew,
    Languages.herero,
    Languages.hindi,
    Languages.hiriMotu,
    Languages.hungarian,
    Languages.icelandic,
    Languages.ido,
    Languages.igbo,
    Languages.indonesian,
    Languages.interlingua,
    Languages.interlingue,
    Languages.inuktitut,
    Languages.inupiaq,
    Languages.irish,
    Languages.italian,
    Languages.japanese,
    Languages.javanese,
    Languages.kalaallisut,
    Languages.kannada,
    Languages.kanuri,
    Languages.kashmiri,
    Languages.kazakh,
    Languages.kikuyu,
    Languages.kinyarwanda,
    Languages.kirghiz,
    Languages.komi,
    Languages.kongo,
    Languages.korean,
    Languages.kuanyama,
    Languages.kurdish,
    Languages.lao,
    Languages.latin,
    Languages.latvian,
    Languages.limburgan,
    Languages.lingala,
    Languages.lithuanian,
    Languages.lubaKatanga,
    Languages.luxembourgish,
    Languages.macedonian,
    Languages.malagasy,
    Languages.malay,
    Languages.malayalam,
    Languages.maltese,
    Languages.manx,
    Languages.maori,
    Languages.marathi,
    Languages.marshallese,
    Languages.mongolian,
    Languages.nauru,
    Languages.navajo,
    Languages.ndebeleNorth,
    Languages.ndebeleSouth,
    Languages.ndonga,
    Languages.nepali,
    Languages.northernSami,
    Languages.norwegian,
    Languages.norwegianNynorsk,
    Languages.occitan,
    Languages.ojibwa,
    Languages.oriya,
    Languages.oromo,
    Languages.ossetian,
    Languages.pali,
    Languages.panjabi,
    Languages.persian,
    Languages.polish,
    Languages.portuguese,
    Languages.pushto,
    Languages.quechua,
    Languages.romanian,
    Languages.romansh,
    Languages.rundi,
    Languages.russian,
    Languages.samoan,
    Languages.sango,
    Languages.sanskrit,
    Languages.sardinian,
    Languages.serbian,
    Languages.shona,
    Languages.sichuanYi,
    Languages.sindhi,
    Languages.sinhala,
    Languages.slovak,
    Languages.slovenian,
    Languages.somali,
    Languages.sothoSouthern,
    Languages.spanish,
    Languages.sundanese,
    Languages.swahili,
    Languages.swati,
    Languages.swedish,
    Languages.tagalog,
    Languages.tahitian,
    Languages.tajik,
    Languages.tamil,
    Languages.tatar,
    Languages.telugu,
    Languages.thai,
    Languages.tibetan,
    Languages.tigrinya,
    Languages.tongaTongaIslands,
    Languages.tsonga,
    Languages.tswana,
    Languages.turkish,
    Languages.turkmen,
    Languages.twi,
    Languages.uighur,
    Languages.ukrainian,
    Languages.urdu,
    Languages.uzbek,
    Languages.venda,
    Languages.vietnamese,
    Languages.volapuk,
    Languages.walloon,
    Languages.welsh,
    Languages.westernFrisian,
    Languages.wolof,
    Languages.xhosa,
    Languages.yiddish,
    Languages.yoruba,
    Languages.zhuang,
    Languages.zulu,
  ];
}

final Map<String, (String country, String language, String languageTag)>
countryCodeToLanguage = {
  'af': ('afghanistan', 'dari', 'fa-af'),
  'al': ('albania', 'albanian', 'sq'),
  'dz': ('algeria', 'arabic', 'ar'),
  'ad': ('andorra', 'catalan', 'ca'),
  'ao': ('angola', 'portuguese', 'pt'),
  'ag': ('antigua and barbuda', 'english', 'en'),
  'ar': ('argentina', 'spanish', 'es'),
  'am': ('armenia', 'armenian', 'hy'),
  'au': ('australia', 'english', 'en'),
  'at': ('austria', 'german', 'de'),
  'az': ('azerbaijan', 'azerbaijani', 'az'),
  'bs': ('bahamas', 'english', 'en'),
  'bh': ('bahrain', 'arabic', 'ar'),
  'bd': ('bangladesh', 'bengali', 'bn'),
  'bb': ('barbados', 'english', 'en'),
  'by': ('belarus', 'belarusian', 'be'),
  'be': ('belgium', 'dutch', 'nl'),
  'bz': ('belize', 'english', 'en'),
  'bj': ('benin', 'french', 'fr'),
  'bt': ('bhutan', 'dzongkha', 'dz'),
  'bo': ('bolivia', 'spanish', 'es'),
  'ba': ('bosnia and herzegovina', 'bosnian', 'bs'),
  'bw': ('botswana', 'english', 'en'),
  'br': ('brazil', 'portuguese', 'pt-br'),
  'bn': ('brunei', 'malay', 'ms'),
  'bg': ('bulgaria', 'bulgarian', 'bg'),
  'bf': ('burkina faso', 'french', 'fr'),
  'bi': ('burundi', 'kirundi', 'rn'),
  'kh': ('cambodia', 'khmer', 'km'),
  'cm': ('cameroon', 'french', 'fr'),
  'ca': ('canada', 'english', 'en'),
  'cv': ('cape verde', 'portuguese', 'pt'),
  'cf': ('central african republic', 'french', 'fr'),
  'td': ('chad', 'arabic', 'ar'),
  'cl': ('chile', 'spanish', 'es'),
  'cn': ('china', 'chinese (mandarin)', 'zh-hans'),
  'co': ('colombia', 'spanish', 'es'),
  'km': ('comoros', 'arabic', 'ar'),
  'cg': ('congo', 'french', 'fr'),
  'cr': ('costa rica', 'spanish', 'es'),
  'ci': ("côte d'ivoire", 'french', 'fr'),
  'hr': ('croatia', 'croatian', 'hr'),
  'cu': ('cuba', 'spanish', 'es'),
  'cy': ('cyprus', 'greek', 'el'),
  'cz': ('czech republic', 'czech', 'cs'),
  'cd': ('democratic republic of the congo', 'french', 'fr'),
  'dk': ('denmark', 'danish', 'da'),
  'dj': ('djibouti', 'arabic', 'ar'),
  'dm': ('dominica', 'english', 'en'),
  'do': ('dominican republic', 'spanish', 'es'),
  'ec': ('ecuador', 'spanish', 'es'),
  'eg': ('egypt', 'arabic', 'ar'),
  'sv': ('el salvador', 'spanish', 'es'),
  'gq': ('equatorial guinea', 'spanish', 'es'),
  'er': ('eritrea', 'tigrinya', 'ti'),
  'ee': ('estonia', 'estonian', 'et'),
  'et': ('ethiopia', 'amharic', 'am'),
  'fj': ('fiji', 'fijian', 'fj'),
  'fi': ('finland', 'finnish', 'fi'),
  'fr': ('france', 'french', 'fr'),
  'ga': ('gabon', 'french', 'fr'),
  'gm': ('gambia', 'english', 'en'),
  'ge': ('georgia', 'georgian', 'ka'),
  'de': ('germany', 'german', 'de'),
  'gh': ('ghana', 'english', 'en'),
  'gr': ('greece', 'greek', 'el'),
  'gd': ('grenada', 'english', 'en'),
  'gt': ('guatemala', 'spanish', 'es'),
  'gn': ('guinea', 'french', 'fr'),
  'gw': ('guinea-bissau', 'portuguese', 'pt'),
  'gy': ('guyana', 'english', 'en'),
  'ht': ('haiti', 'french', 'fr'),
  'hn': ('honduras', 'spanish', 'es'),
  'hu': ('hungary', 'hungarian', 'hu'),
  'is': ('iceland', 'icelandic', 'is'),
  'in': ('india', 'hindi', 'hi'),
  'id': ('indonesia', 'indonesian', 'id'),
  'ir': ('iran', 'persian', 'fa-ir'),
  'iq': ('iraq', 'arabic', 'ar'),
  'ie': ('ireland', 'irish', 'ga'),
  'il': ('israel', 'hebrew', 'he'),
  'it': ('italy', 'italian', 'it'),
  'jm': ('jamaica', 'english', 'en'),
  'jp': ('japan', 'japanese', 'ja'),
  'jo': ('jordan', 'arabic', 'ar'),
  'kz': ('kazakhstan', 'kazakh', 'kk'),
  'ke': ('kenya', 'english', 'en'),
  'ki': ('kiribati', 'english', 'en'),
  'kw': ('kuwait', 'arabic', 'ar'),
  'kg': ('kyrgyzstan', 'kyrgyz', 'ky'),
  'la': ('laos', 'lao', 'lo'),
  'lv': ('latvia', 'latvian', 'lv'),
  'lb': ('lebanon', 'arabic', 'ar'),
  'ls': ('lesotho', 'english', 'en'),
  'lr': ('liberia', 'english', 'en'),
  'ly': ('libya', 'arabic', 'ar'),
  'li': ('liechtenstein', 'german', 'de'),
  'lt': ('lithuania', 'lithuanian', 'lt'),
  'lu': ('luxembourg', 'luxembourgish', 'lb'),
  'mk': ('north macedonia', 'macedonian', 'mk'),
  'mg': ('madagascar', 'malagasy', 'mg'),
  'mw': ('malawi', 'english', 'en'),
  'my': ('malaysia', 'malay', 'ms'),
  'mv': ('maldives', 'dhivehi', 'dv'),
  'ml': ('mali', 'french', 'fr'),
  'mt': ('malta', 'maltese', 'mt'),
  'mh': ('marshall islands', 'english', 'en'),
  'mr': ('mauritania', 'arabic', 'ar'),
  'mu': ('mauritius', 'english', 'en'),
  'mx': ('mexico', 'spanish', 'es'),
  'fm': ('micronesia', 'english', 'en'),
  'md': ('moldova', 'moldovan', 'mo'),
  'mc': ('monaco', 'french', 'fr'),
  'mn': ('mongolia', 'mongolian', 'mn'),
  'me': ('montenegro', 'montenegrin', 'me'),
  'ma': ('morocco', 'arabic', 'ar'),
  'mz': ('mozambique', 'portuguese', 'pt'),
  'mm': ('myanmar', 'burmese', 'my'),
  'na': ('namibia', 'english', 'en'),
  'nr': ('nauru', 'nauruan', 'na'),
  'np': ('nepal', 'nepali', 'ne'),
  'nl': ('netherlands', 'dutch', 'nl'),
  'nz': ('new zealand', 'english', 'en'),
  'ni': ('nicaragua', 'spanish', 'es'),
  'ne': ('niger', 'french', 'fr'),
  'ng': ('nigeria', 'english', 'en'),
  'nu': ('niue', 'niuean', 'niu'),
  'kp': ('north korea', 'korean', 'ko'),
  'no': ('norway', 'norwegian bokmål', 'nb'),
  'om': ('oman', 'arabic', 'ar'),
  'pk': ('pakistan', 'urdu', 'ur'),
  'pw': ('palau', 'palauan', 'pau'),
  'ps': ('palestine', 'arabic', 'ar'),
  'pa': ('panama', 'spanish', 'es'),
  'pg': ('papua new guinea', 'tok pisin', 'tpi'),
  'py': ('paraguay', 'spanish', 'es'),
  'pe': ('peru', 'spanish', 'es'),
  'ph': ('philippines', 'filipino', 'fil'),
  'pl': ('poland', 'polish', 'pl'),
  'pt': ('portugal', 'portuguese', 'pt'),
  'qa': ('qatar', 'arabic', 'ar'),
  're': ('réunion', 'french', 'fr'),
  'ro': ('romania', 'romanian', 'ro'),
  'ru': ('russia', 'russian', 'ru'),
  'rw': ('rwanda', 'kinyarwanda', 'rw'),
  'ws': ('samoa', 'samoan', 'sm'),
  'sm': ('san marino', 'italian', 'it'),
  'st': ('são tomé and príncipe', 'portuguese', 'pt'),
  'sa': ('saudi arabia', 'arabic', 'ar'),
  'sn': ('senegal', 'french', 'fr'),
  'rs': ('serbia', 'serbian', 'sr'),
  'sc': ('seychelles', 'seychellois creole', 'sc'),
  'sl': ('sierra leone', 'english', 'en'),
  'sg': ('singapore', 'english', 'en'),
  'sk': ('slovakia', 'slovak', 'sk'),
  'si': ('slovenia', 'slovenian', 'sl'),
  'sb': ('solomon islands', 'solomon islands pidgin', 'en'),
  'so': ('somalia', 'somali', 'so'),
  'za': ('south africa', 'afrikaans', 'af'),
  'kr': ('south korea', 'korean', 'ko'),
  'ss': ('south sudan', 'english', 'en'),
  'es': ('spain', 'spanish', 'es'),
  'lk': ('sri lanka', 'sinhala', 'si'),
  'sd': ('sudan', 'arabic', 'ar'),
  'sr': ('suriname', 'dutch', 'nl'),
  'sz': ('eswatini', 'english', 'en'),
  'se': ('sweden', 'swedish', 'sv'),
  'ch': ('switzerland', 'german', 'de'),
  'sy': ('syria', 'arabic', 'ar'),
  'tw': ('taiwan', 'mandarin chinese', 'zh-hans'),
  'tj': ('tajikistan', 'tajik', 'tg'),
  'th': ('thailand', 'thai', 'th'),
  'tl': ('timor-leste', 'tetum', 'tet'),
  'tg': ('togo', 'french', 'fr'),
  'tk': ('tokelau', 'tokelauan', 'tok'),
  'to': ('tonga', 'tongan', 'to'),
  'tt': ('trinidad and tobago', 'english', 'en'),
  'tn': ('tunisia', 'arabic', 'ar'),
  'tr': ('turkey', 'turkish', 'tr'),
  'tm': ('turkmenistan', 'turkmen', 'tk'),
  'tv': ('tuvalu', 'tuvaluan', 'tvl'),
  'ug': ('uganda', 'english', 'en'),
  'ua': ('ukraine', 'ukrainian', 'uk'),
  'ae': ('united arab emirates', 'arabic', 'ar'),
  'gb': ('united kingdom', 'english', 'en'),
  'us': ('united states', 'english', 'en'),
  'uy': ('uruguay', 'spanish', 'es'),
  'uz': ('uzbekistan', 'uzbek', 'uz'),
  'vu': ('vanuatu', 'bislama', 'bi'),
  'va': ('vatican city', 'italian', 'it'),
  've': ('venezuela', 'spanish', 'es'),
  'vn': ('vietnam', 'vietnamese', 'vi'),
  'ye': ('yemen', 'arabic', 'ar'),
  'zm': ('zambia', 'english', 'en'),
  'zw': ('zimbabwe', 'shona', 'sn'),
  'xk': ('kosovo', 'albanian', 'sq'),
  'yt': ('mayotte', 'french', 'fr'),
  'wf': ('wallis and futuna', 'french', 'fr'),
  'eh': ('western sahara', 'arabic', 'ar'),
};
