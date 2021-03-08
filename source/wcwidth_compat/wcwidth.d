/*
 * Copyright (C) Fredrik Fornwall 2016.
 * Distributed under the MIT License.
 *
 * Implementation of wcwidth(3) as a C port of:
 * https://github.com/jquast/wcwidth
 *
 * Report issues at:
 * https://github.com/termux/wcwidth
 *
 * IMPORTANT:
 * Must be kept in sync with the following:
 * https://github.com/termux/termux-app/blob/master/terminal-emulator/src/main/java/com/termux/terminal/WcWidth.java
 * https://github.com/termux/libandroid-support
 * https://github.com/termux/termux-packages/tree/master/libandroid-support
 */
module wcwidth_compat.wcwidth;


private struct width_interval
{
	uint start;
	uint end;
}

/*
 * From https://github.com/jquast/wcwidth/blob/master/wcwidth/table_zero.py
 * at commit b29897e5a1b403a0e36f7fc991614981cbc42475 (2020-07-14):
 */
private static immutable .width_interval[] ZERO_WIDTH =
[
	// Combining Grave Accent  ..Combining Latin Small Le
	{0x000300, 0x00036F},

	// Combining Cyrillic Titlo..Combining Cyrillic Milli
	{0x000483, 0x000489},

	// Hebrew Accent Etnahta   ..Hebrew Point Meteg
	{0x000591, 0x0005BD},

	// Hebrew Point Rafe       ..Hebrew Point Rafe
	{0x0005BF, 0x0005BF},

	// Hebrew Point Shin Dot   ..Hebrew Point Sin Dot
	{0x0005C1, 0x0005C2},

	// Hebrew Mark Upper Dot   ..Hebrew Mark Lower Dot
	{0x0005C4, 0x0005C5},

	// Hebrew Point Qamats Qata..Hebrew Point Qamats Qata
	{0x0005C7, 0x0005C7},

	// Arabic Sign Sallallahou ..Arabic Small Kasra
	{0x000610, 0x00061A},

	// Arabic Fathatan         ..Arabic Wavy Hamza Below
	{0x00064B, 0x00065F},

	// Arabic Letter Superscrip..Arabic Letter Superscrip
	{0x000670, 0x000670},

	// Arabic Small High Ligatu..Arabic Small High Seen
	{0x0006D6, 0x0006DC},

	// Arabic Small High Rounde..Arabic Small High Madda
	{0x0006DF, 0x0006E4},

	// Arabic Small High Yeh   ..Arabic Small High Noon
	{0x0006E7, 0x0006E8},

	// Arabic Empty Centre Low ..Arabic Small Low Meem
	{0x0006EA, 0x0006ED},

	// Syriac Letter Superscrip..Syriac Letter Superscrip
	{0x000711, 0x000711},

	// Syriac Pthaha Above     ..Syriac Barrekh
	{0x000730, 0x00074A},

	// Thaana Abafili          ..Thaana Sukun
	{0x0007A6, 0x0007B0},

	// Nko Combining Short High..Nko Combining Double Dot
	{0x0007EB, 0x0007F3},

	// Nko Dantayalan          ..Nko Dantayalan
	{0x0007FD, 0x0007FD},

	// Samaritan Mark In       ..Samaritan Mark Dagesh
	{0x000816, 0x000819},

	// Samaritan Mark Epentheti..Samaritan Vowel Sign A
	{0x00081B, 0x000823},

	// Samaritan Vowel Sign Sho..Samaritan Vowel Sign U
	{0x000825, 0x000827},

	// Samaritan Vowel Sign Lon..Samaritan Mark Nequdaa
	{0x000829, 0x00082D},

	// Mandaic Affrication Mark..Mandaic Gemination Mark
	{0x000859, 0x00085B},

	// Arabic Small Low Waw    ..Arabic Small High Sign S
	{0x0008D3, 0x0008E1},

	// Arabic Turned Damma Belo..Devanagari Sign Anusvara
	{0x0008E3, 0x000902},

	// Devanagari Vowel Sign Oe..Devanagari Vowel Sign Oe
	{0x00093A, 0x00093A},

	// Devanagari Sign Nukta   ..Devanagari Sign Nukta
	{0x00093C, 0x00093C},

	// Devanagari Vowel Sign U ..Devanagari Vowel Sign Ai
	{0x000941, 0x000948},

	// Devanagari Sign Virama  ..Devanagari Sign Virama
	{0x00094D, 0x00094D},

	// Devanagari Stress Sign U..Devanagari Vowel Sign Uu
	{0x000951, 0x000957},

	// Devanagari Vowel Sign Vo..Devanagari Vowel Sign Vo
	{0x000962, 0x000963},

	// Bengali Sign Candrabindu..Bengali Sign Candrabindu
	{0x000981, 0x000981},

	// Bengali Sign Nukta      ..Bengali Sign Nukta
	{0x0009BC, 0x0009BC},

	// Bengali Vowel Sign U    ..Bengali Vowel Sign Vocal
	{0x0009C1, 0x0009C4},

	// Bengali Sign Virama     ..Bengali Sign Virama
	{0x0009CD, 0x0009CD},

	// Bengali Vowel Sign Vocal..Bengali Vowel Sign Vocal
	{0x0009E2, 0x0009E3},

	// Bengali Sandhi Mark     ..Bengali Sandhi Mark
	{0x0009FE, 0x0009FE},

	// Gurmukhi Sign Adak Bindi..Gurmukhi Sign Bindi
	{0x000A01, 0x000A02},

	// Gurmukhi Sign Nukta     ..Gurmukhi Sign Nukta
	{0x000A3C, 0x000A3C},

	// Gurmukhi Vowel Sign U   ..Gurmukhi Vowel Sign Uu
	{0x000A41, 0x000A42},

	// Gurmukhi Vowel Sign Ee  ..Gurmukhi Vowel Sign Ai
	{0x000A47, 0x000A48},

	// Gurmukhi Vowel Sign Oo  ..Gurmukhi Sign Virama
	{0x000A4B, 0x000A4D},

	// Gurmukhi Sign Udaat     ..Gurmukhi Sign Udaat
	{0x000A51, 0x000A51},

	// Gurmukhi Tippi          ..Gurmukhi Addak
	{0x000A70, 0x000A71},

	// Gurmukhi Sign Yakash    ..Gurmukhi Sign Yakash
	{0x000A75, 0x000A75},

	// Gujarati Sign Candrabind..Gujarati Sign Anusvara
	{0x000A81, 0x000A82},

	// Gujarati Sign Nukta     ..Gujarati Sign Nukta
	{0x000ABC, 0x000ABC},

	// Gujarati Vowel Sign U   ..Gujarati Vowel Sign Cand
	{0x000AC1, 0x000AC5},

	// Gujarati Vowel Sign E   ..Gujarati Vowel Sign Ai
	{0x000AC7, 0x000AC8},

	// Gujarati Sign Virama    ..Gujarati Sign Virama
	{0x000ACD, 0x000ACD},

	// Gujarati Vowel Sign Voca..Gujarati Vowel Sign Voca
	{0x000AE2, 0x000AE3},

	// Gujarati Sign Sukun     ..Gujarati Sign Two-circle
	{0x000AFA, 0x000AFF},

	// Oriya Sign Candrabindu  ..Oriya Sign Candrabindu
	{0x000B01, 0x000B01},

	// Oriya Sign Nukta        ..Oriya Sign Nukta
	{0x000B3C, 0x000B3C},

	// Oriya Vowel Sign I      ..Oriya Vowel Sign I
	{0x000B3F, 0x000B3F},

	// Oriya Vowel Sign U      ..Oriya Vowel Sign Vocalic
	{0x000B41, 0x000B44},

	// Oriya Sign Virama       ..Oriya Sign Virama
	{0x000B4D, 0x000B4D},

	// (nil)                   ..Oriya Ai Length Mark
	{0x000B55, 0x000B56},

	// Oriya Vowel Sign Vocalic..Oriya Vowel Sign Vocalic
	{0x000B62, 0x000B63},

	// Tamil Sign Anusvara     ..Tamil Sign Anusvara
	{0x000B82, 0x000B82},

	// Tamil Vowel Sign Ii     ..Tamil Vowel Sign Ii
	{0x000BC0, 0x000BC0},

	// Tamil Sign Virama       ..Tamil Sign Virama
	{0x000BCD, 0x000BCD},

	// Telugu Sign Combining Ca..Telugu Sign Combining Ca
	{0x000C00, 0x000C00},

	// Telugu Sign Combining An..Telugu Sign Combining An
	{0x000C04, 0x000C04},

	// Telugu Vowel Sign Aa    ..Telugu Vowel Sign Ii
	{0x000C3E, 0x000C40},

	// Telugu Vowel Sign E     ..Telugu Vowel Sign Ai
	{0x000C46, 0x000C48},

	// Telugu Vowel Sign O     ..Telugu Sign Virama
	{0x000C4A, 0x000C4D},

	// Telugu Length Mark      ..Telugu Ai Length Mark
	{0x000C55, 0x000C56},

	// Telugu Vowel Sign Vocali..Telugu Vowel Sign Vocali
	{0x000C62, 0x000C63},

	// Kannada Sign Candrabindu..Kannada Sign Candrabindu
	{0x000C81, 0x000C81},

	// Kannada Sign Nukta      ..Kannada Sign Nukta
	{0x000CBC, 0x000CBC},

	// Kannada Vowel Sign I    ..Kannada Vowel Sign I
	{0x000CBF, 0x000CBF},

	// Kannada Vowel Sign E    ..Kannada Vowel Sign E
	{0x000CC6, 0x000CC6},

	// Kannada Vowel Sign Au   ..Kannada Sign Virama
	{0x000CCC, 0x000CCD},

	// Kannada Vowel Sign Vocal..Kannada Vowel Sign Vocal
	{0x000CE2, 0x000CE3},

	// Malayalam Sign Combining..Malayalam Sign Candrabin
	{0x000D00, 0x000D01},

	// Malayalam Sign Vertical ..Malayalam Sign Circular
	{0x000D3B, 0x000D3C},

	// Malayalam Vowel Sign U  ..Malayalam Vowel Sign Voc
	{0x000D41, 0x000D44},

	// Malayalam Sign Virama   ..Malayalam Sign Virama
	{0x000D4D, 0x000D4D},

	// Malayalam Vowel Sign Voc..Malayalam Vowel Sign Voc
	{0x000D62, 0x000D63},

	// (nil)                   ..(nil)
	{0x000D81, 0x000D81},

	// Sinhala Sign Al-lakuna  ..Sinhala Sign Al-lakuna
	{0x000DCA, 0x000DCA},

	// Sinhala Vowel Sign Ketti..Sinhala Vowel Sign Ketti
	{0x000DD2, 0x000DD4},

	// Sinhala Vowel Sign Diga ..Sinhala Vowel Sign Diga
	{0x000DD6, 0x000DD6},

	// Thai Character Mai Han-a..Thai Character Mai Han-a
	{0x000E31, 0x000E31},

	// Thai Character Sara I   ..Thai Character Phinthu
	{0x000E34, 0x000E3A},

	// Thai Character Maitaikhu..Thai Character Yamakkan
	{0x000E47, 0x000E4E},

	// Lao Vowel Sign Mai Kan  ..Lao Vowel Sign Mai Kan
	{0x000EB1, 0x000EB1},

	// Lao Vowel Sign I        ..Lao Semivowel Sign Lo
	{0x000EB4, 0x000EBC},

	// Lao Tone Mai Ek         ..Lao Niggahita
	{0x000EC8, 0x000ECD},

	// Tibetan Astrological Sig..Tibetan Astrological Sig
	{0x000F18, 0x000F19},

	// Tibetan Mark Ngas Bzung ..Tibetan Mark Ngas Bzung
	{0x000F35, 0x000F35},

	// Tibetan Mark Ngas Bzung ..Tibetan Mark Ngas Bzung
	{0x000F37, 0x000F37},

	// Tibetan Mark Tsa -phru  ..Tibetan Mark Tsa -phru
	{0x000F39, 0x000F39},

	// Tibetan Vowel Sign Aa   ..Tibetan Sign Rjes Su Nga
	{0x000F71, 0x000F7E},

	// Tibetan Vowel Sign Rever..Tibetan Mark Halanta
	{0x000F80, 0x000F84},

	// Tibetan Sign Lci Rtags  ..Tibetan Sign Yang Rtags
	{0x000F86, 0x000F87},

	// Tibetan Subjoined Sign L..Tibetan Subjoined Letter
	{0x000F8D, 0x000F97},

	// Tibetan Subjoined Letter..Tibetan Subjoined Letter
	{0x000F99, 0x000FBC},

	// Tibetan Symbol Padma Gda..Tibetan Symbol Padma Gda
	{0x000FC6, 0x000FC6},

	// Myanmar Vowel Sign I    ..Myanmar Vowel Sign Uu
	{0x00102D, 0x001030},

	// Myanmar Vowel Sign Ai   ..Myanmar Sign Dot Below
	{0x001032, 0x001037},

	// Myanmar Sign Virama     ..Myanmar Sign Asat
	{0x001039, 0x00103A},

	// Myanmar Consonant Sign M..Myanmar Consonant Sign M
	{0x00103D, 0x00103E},

	// Myanmar Vowel Sign Vocal..Myanmar Vowel Sign Vocal
	{0x001058, 0x001059},

	// Myanmar Consonant Sign M..Myanmar Consonant Sign M
	{0x00105E, 0x001060},

	// Myanmar Vowel Sign Geba ..Myanmar Vowel Sign Kayah
	{0x001071, 0x001074},

	// Myanmar Consonant Sign S..Myanmar Consonant Sign S
	{0x001082, 0x001082},

	// Myanmar Vowel Sign Shan ..Myanmar Vowel Sign Shan
	{0x001085, 0x001086},

	// Myanmar Sign Shan Counci..Myanmar Sign Shan Counci
	{0x00108D, 0x00108D},

	// Myanmar Vowel Sign Aiton..Myanmar Vowel Sign Aiton
	{0x00109D, 0x00109D},

	// Ethiopic Combining Gemin..Ethiopic Combining Gemin
	{0x00135D, 0x00135F},

	// Tagalog Vowel Sign I    ..Tagalog Sign Virama
	{0x001712, 0x001714},

	// Hanunoo Vowel Sign I    ..Hanunoo Sign Pamudpod
	{0x001732, 0x001734},

	// Buhid Vowel Sign I      ..Buhid Vowel Sign U
	{0x001752, 0x001753},

	// Tagbanwa Vowel Sign I   ..Tagbanwa Vowel Sign U
	{0x001772, 0x001773},

	// Khmer Vowel Inherent Aq ..Khmer Vowel Inherent Aa
	{0x0017B4, 0x0017B5},

	// Khmer Vowel Sign I      ..Khmer Vowel Sign Ua
	{0x0017B7, 0x0017BD},

	// Khmer Sign Nikahit      ..Khmer Sign Nikahit
	{0x0017C6, 0x0017C6},

	// Khmer Sign Muusikatoan  ..Khmer Sign Bathamasat
	{0x0017C9, 0x0017D3},

	// Khmer Sign Atthacan     ..Khmer Sign Atthacan
	{0x0017DD, 0x0017DD},

	// Mongolian Free Variation..Mongolian Free Variation
	{0x00180B, 0x00180D},

	// Mongolian Letter Ali Gal..Mongolian Letter Ali Gal
	{0x001885, 0x001886},

	// Mongolian Letter Ali Gal..Mongolian Letter Ali Gal
	{0x0018A9, 0x0018A9},

	// Limbu Vowel Sign A      ..Limbu Vowel Sign U
	{0x001920, 0x001922},

	// Limbu Vowel Sign E      ..Limbu Vowel Sign O
	{0x001927, 0x001928},

	// Limbu Small Letter Anusv..Limbu Small Letter Anusv
	{0x001932, 0x001932},

	// Limbu Sign Mukphreng    ..Limbu Sign Sa-i
	{0x001939, 0x00193B},

	// Buginese Vowel Sign I   ..Buginese Vowel Sign U
	{0x001A17, 0x001A18},

	// Buginese Vowel Sign Ae  ..Buginese Vowel Sign Ae
	{0x001A1B, 0x001A1B},

	// Tai Tham Consonant Sign ..Tai Tham Consonant Sign
	{0x001A56, 0x001A56},

	// Tai Tham Sign Mai Kang L..Tai Tham Consonant Sign
	{0x001A58, 0x001A5E},

	// Tai Tham Sign Sakot     ..Tai Tham Sign Sakot
	{0x001A60, 0x001A60},

	// Tai Tham Vowel Sign Mai ..Tai Tham Vowel Sign Mai
	{0x001A62, 0x001A62},

	// Tai Tham Vowel Sign I   ..Tai Tham Vowel Sign Oa B
	{0x001A65, 0x001A6C},

	// Tai Tham Vowel Sign Oa A..Tai Tham Sign Khuen-lue
	{0x001A73, 0x001A7C},

	// Tai Tham Combining Crypt..Tai Tham Combining Crypt
	{0x001A7F, 0x001A7F},

	// Combining Doubled Circum..(nil)
	{0x001AB0, 0x001AC0},

	// Balinese Sign Ulu Ricem ..Balinese Sign Surang
	{0x001B00, 0x001B03},

	// Balinese Sign Rerekan   ..Balinese Sign Rerekan
	{0x001B34, 0x001B34},

	// Balinese Vowel Sign Ulu ..Balinese Vowel Sign Ra R
	{0x001B36, 0x001B3A},

	// Balinese Vowel Sign La L..Balinese Vowel Sign La L
	{0x001B3C, 0x001B3C},

	// Balinese Vowel Sign Pepe..Balinese Vowel Sign Pepe
	{0x001B42, 0x001B42},

	// Balinese Musical Symbol ..Balinese Musical Symbol
	{0x001B6B, 0x001B73},

	// Sundanese Sign Panyecek ..Sundanese Sign Panglayar
	{0x001B80, 0x001B81},

	// Sundanese Consonant Sign..Sundanese Vowel Sign Pan
	{0x001BA2, 0x001BA5},

	// Sundanese Vowel Sign Pam..Sundanese Vowel Sign Pan
	{0x001BA8, 0x001BA9},

	// Sundanese Sign Virama   ..Sundanese Consonant Sign
	{0x001BAB, 0x001BAD},

	// Batak Sign Tompi        ..Batak Sign Tompi
	{0x001BE6, 0x001BE6},

	// Batak Vowel Sign Pakpak ..Batak Vowel Sign Ee
	{0x001BE8, 0x001BE9},

	// Batak Vowel Sign Karo O ..Batak Vowel Sign Karo O
	{0x001BED, 0x001BED},

	// Batak Vowel Sign U For S..Batak Consonant Sign H
	{0x001BEF, 0x001BF1},

	// Lepcha Vowel Sign E     ..Lepcha Consonant Sign T
	{0x001C2C, 0x001C33},

	// Lepcha Sign Ran         ..Lepcha Sign Nukta
	{0x001C36, 0x001C37},

	// Vedic Tone Karshana     ..Vedic Tone Prenkha
	{0x001CD0, 0x001CD2},

	// Vedic Sign Yajurvedic Mi..Vedic Tone Rigvedic Kash
	{0x001CD4, 0x001CE0},

	// Vedic Sign Visarga Svari..Vedic Sign Visarga Anuda
	{0x001CE2, 0x001CE8},

	// Vedic Sign Tiryak       ..Vedic Sign Tiryak
	{0x001CED, 0x001CED},

	// Vedic Tone Candra Above ..Vedic Tone Candra Above
	{0x001CF4, 0x001CF4},

	// Vedic Tone Ring Above   ..Vedic Tone Double Ring A
	{0x001CF8, 0x001CF9},

	// Combining Dotted Grave A..Combining Wide Inverted
	{0x001DC0, 0x001DF9},

	// Combining Deletion Mark ..Combining Right Arrowhea
	{0x001DFB, 0x001DFF},

	// Combining Left Harpoon A..Combining Asterisk Above
	{0x0020D0, 0x0020F0},

	// Coptic Combining Ni Abov..Coptic Combining Spiritu
	{0x002CEF, 0x002CF1},

	// Tifinagh Consonant Joine..Tifinagh Consonant Joine
	{0x002D7F, 0x002D7F},

	// Combining Cyrillic Lette..Combining Cyrillic Lette
	{0x002DE0, 0x002DFF},

	// Ideographic Level Tone M..Ideographic Entering Ton
	{0x00302A, 0x00302D},

	// Combining Katakana-hirag..Combining Katakana-hirag
	{0x003099, 0x00309A},

	// Combining Cyrillic Vzmet..Combining Cyrillic Thous
	{0x00A66F, 0x00A672},

	// Combining Cyrillic Lette..Combining Cyrillic Payer
	{0x00A674, 0x00A67D},

	// Combining Cyrillic Lette..Combining Cyrillic Lette
	{0x00A69E, 0x00A69F},

	// Bamum Combining Mark Koq..Bamum Combining Mark Tuk
	{0x00A6F0, 0x00A6F1},

	// Syloti Nagri Sign Dvisva..Syloti Nagri Sign Dvisva
	{0x00A802, 0x00A802},

	// Syloti Nagri Sign Hasant..Syloti Nagri Sign Hasant
	{0x00A806, 0x00A806},

	// Syloti Nagri Sign Anusva..Syloti Nagri Sign Anusva
	{0x00A80B, 0x00A80B},

	// Syloti Nagri Vowel Sign ..Syloti Nagri Vowel Sign
	{0x00A825, 0x00A826},

	// (nil)                   ..(nil)
	{0x00A82C, 0x00A82C},

	// Saurashtra Sign Virama  ..Saurashtra Sign Candrabi
	{0x00A8C4, 0x00A8C5},

	// Combining Devanagari Dig..Combining Devanagari Sig
	{0x00A8E0, 0x00A8F1},

	// Devanagari Vowel Sign Ay..Devanagari Vowel Sign Ay
	{0x00A8FF, 0x00A8FF},

	// Kayah Li Vowel Ue       ..Kayah Li Tone Calya Plop
	{0x00A926, 0x00A92D},

	// Rejang Vowel Sign I     ..Rejang Consonant Sign R
	{0x00A947, 0x00A951},

	// Javanese Sign Panyangga ..Javanese Sign Layar
	{0x00A980, 0x00A982},

	// Javanese Sign Cecak Telu..Javanese Sign Cecak Telu
	{0x00A9B3, 0x00A9B3},

	// Javanese Vowel Sign Wulu..Javanese Vowel Sign Suku
	{0x00A9B6, 0x00A9B9},

	// Javanese Vowel Sign Pepe..Javanese Consonant Sign
	{0x00A9BC, 0x00A9BD},

	// Myanmar Sign Shan Saw   ..Myanmar Sign Shan Saw
	{0x00A9E5, 0x00A9E5},

	// Cham Vowel Sign Aa      ..Cham Vowel Sign Oe
	{0x00AA29, 0x00AA2E},

	// Cham Vowel Sign Au      ..Cham Vowel Sign Ue
	{0x00AA31, 0x00AA32},

	// Cham Consonant Sign La  ..Cham Consonant Sign Wa
	{0x00AA35, 0x00AA36},

	// Cham Consonant Sign Fina..Cham Consonant Sign Fina
	{0x00AA43, 0x00AA43},

	// Cham Consonant Sign Fina..Cham Consonant Sign Fina
	{0x00AA4C, 0x00AA4C},

	// Myanmar Sign Tai Laing T..Myanmar Sign Tai Laing T
	{0x00AA7C, 0x00AA7C},

	// Tai Viet Mai Kang       ..Tai Viet Mai Kang
	{0x00AAB0, 0x00AAB0},

	// Tai Viet Vowel I        ..Tai Viet Vowel U
	{0x00AAB2, 0x00AAB4},

	// Tai Viet Mai Khit       ..Tai Viet Vowel Ia
	{0x00AAB7, 0x00AAB8},

	// Tai Viet Vowel Am       ..Tai Viet Tone Mai Ek
	{0x00AABE, 0x00AABF},

	// Tai Viet Tone Mai Tho   ..Tai Viet Tone Mai Tho
	{0x00AAC1, 0x00AAC1},

	// Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
	{0x00AAEC, 0x00AAED},

	// Meetei Mayek Virama     ..Meetei Mayek Virama
	{0x00AAF6, 0x00AAF6},

	// Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
	{0x00ABE5, 0x00ABE5},

	// Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
	{0x00ABE8, 0x00ABE8},

	// Meetei Mayek Apun Iyek  ..Meetei Mayek Apun Iyek
	{0x00ABED, 0x00ABED},

	// Hebrew Point Judeo-spani..Hebrew Point Judeo-spani
	{0x00FB1E, 0x00FB1E},

	// Variation Selector-1    ..Variation Selector-16
	{0x00FE00, 0x00FE0F},

	// Combining Ligature Left ..Combining Cyrillic Titlo
	{0x00FE20, 0x00FE2F},

	// Phaistos Disc Sign Combi..Phaistos Disc Sign Combi
	{0x0101FD, 0x0101FD},

	// Coptic Epact Thousands M..Coptic Epact Thousands M
	{0x0102E0, 0x0102E0},

	// Combining Old Permic Let..Combining Old Permic Let
	{0x010376, 0x01037A},

	// Kharoshthi Vowel Sign I ..Kharoshthi Vowel Sign Vo
	{0x010A01, 0x010A03},

	// Kharoshthi Vowel Sign E ..Kharoshthi Vowel Sign O
	{0x010A05, 0x010A06},

	// Kharoshthi Vowel Length ..Kharoshthi Sign Visarga
	{0x010A0C, 0x010A0F},

	// Kharoshthi Sign Bar Abov..Kharoshthi Sign Dot Belo
	{0x010A38, 0x010A3A},

	// Kharoshthi Virama       ..Kharoshthi Virama
	{0x010A3F, 0x010A3F},

	// Manichaean Abbreviation ..Manichaean Abbreviation
	{0x010AE5, 0x010AE6},

	// Hanifi Rohingya Sign Har..Hanifi Rohingya Sign Tas
	{0x010D24, 0x010D27},

	// (nil)                   ..(nil)
	{0x010EAB, 0x010EAC},

	// Sogdian Combining Dot Be..Sogdian Combining Stroke
	{0x010F46, 0x010F50},

	// Brahmi Sign Anusvara    ..Brahmi Sign Anusvara
	{0x011001, 0x011001},

	// Brahmi Vowel Sign Aa    ..Brahmi Virama
	{0x011038, 0x011046},

	// Brahmi Number Joiner    ..Kaithi Sign Anusvara
	{0x01107F, 0x011081},

	// Kaithi Vowel Sign U     ..Kaithi Vowel Sign Ai
	{0x0110B3, 0x0110B6},

	// Kaithi Sign Virama      ..Kaithi Sign Nukta
	{0x0110B9, 0x0110BA},

	// Chakma Sign Candrabindu ..Chakma Sign Visarga
	{0x011100, 0x011102},

	// Chakma Vowel Sign A     ..Chakma Vowel Sign Uu
	{0x011127, 0x01112B},

	// Chakma Vowel Sign Ai    ..Chakma Maayyaa
	{0x01112D, 0x011134},

	// Mahajani Sign Nukta     ..Mahajani Sign Nukta
	{0x011173, 0x011173},

	// Sharada Sign Candrabindu..Sharada Sign Anusvara
	{0x011180, 0x011181},

	// Sharada Vowel Sign U    ..Sharada Vowel Sign O
	{0x0111B6, 0x0111BE},

	// Sharada Sandhi Mark     ..Sharada Extra Short Vowe
	{0x0111C9, 0x0111CC},

	// (nil)                   ..(nil)
	{0x0111CF, 0x0111CF},

	// Khojki Vowel Sign U     ..Khojki Vowel Sign Ai
	{0x01122F, 0x011231},

	// Khojki Sign Anusvara    ..Khojki Sign Anusvara
	{0x011234, 0x011234},

	// Khojki Sign Nukta       ..Khojki Sign Shadda
	{0x011236, 0x011237},

	// Khojki Sign Sukun       ..Khojki Sign Sukun
	{0x01123E, 0x01123E},

	// Khudawadi Sign Anusvara ..Khudawadi Sign Anusvara
	{0x0112DF, 0x0112DF},

	// Khudawadi Vowel Sign U  ..Khudawadi Sign Virama
	{0x0112E3, 0x0112EA},

	// Grantha Sign Combining A..Grantha Sign Candrabindu
	{0x011300, 0x011301},

	// Combining Bindu Below   ..Grantha Sign Nukta
	{0x01133B, 0x01133C},

	// Grantha Vowel Sign Ii   ..Grantha Vowel Sign Ii
	{0x011340, 0x011340},

	// Combining Grantha Digit ..Combining Grantha Digit
	{0x011366, 0x01136C},

	// Combining Grantha Letter..Combining Grantha Letter
	{0x011370, 0x011374},

	// Newa Vowel Sign U       ..Newa Vowel Sign Ai
	{0x011438, 0x01143F},

	// Newa Sign Virama        ..Newa Sign Anusvara
	{0x011442, 0x011444},

	// Newa Sign Nukta         ..Newa Sign Nukta
	{0x011446, 0x011446},

	// Newa Sandhi Mark        ..Newa Sandhi Mark
	{0x01145E, 0x01145E},

	// Tirhuta Vowel Sign U    ..Tirhuta Vowel Sign Vocal
	{0x0114B3, 0x0114B8},

	// Tirhuta Vowel Sign Short..Tirhuta Vowel Sign Short
	{0x0114BA, 0x0114BA},

	// Tirhuta Sign Candrabindu..Tirhuta Sign Anusvara
	{0x0114BF, 0x0114C0},

	// Tirhuta Sign Virama     ..Tirhuta Sign Nukta
	{0x0114C2, 0x0114C3},

	// Siddham Vowel Sign U    ..Siddham Vowel Sign Vocal
	{0x0115B2, 0x0115B5},

	// Siddham Sign Candrabindu..Siddham Sign Anusvara
	{0x0115BC, 0x0115BD},

	// Siddham Sign Virama     ..Siddham Sign Nukta
	{0x0115BF, 0x0115C0},

	// Siddham Vowel Sign Alter..Siddham Vowel Sign Alter
	{0x0115DC, 0x0115DD},

	// Modi Vowel Sign U       ..Modi Vowel Sign Ai
	{0x011633, 0x01163A},

	// Modi Sign Anusvara      ..Modi Sign Anusvara
	{0x01163D, 0x01163D},

	// Modi Sign Virama        ..Modi Sign Ardhacandra
	{0x01163F, 0x011640},

	// Takri Sign Anusvara     ..Takri Sign Anusvara
	{0x0116AB, 0x0116AB},

	// Takri Vowel Sign Aa     ..Takri Vowel Sign Aa
	{0x0116AD, 0x0116AD},

	// Takri Vowel Sign U      ..Takri Vowel Sign Au
	{0x0116B0, 0x0116B5},

	// Takri Sign Nukta        ..Takri Sign Nukta
	{0x0116B7, 0x0116B7},

	// Ahom Consonant Sign Medi..Ahom Consonant Sign Medi
	{0x01171D, 0x01171F},

	// Ahom Vowel Sign I       ..Ahom Vowel Sign Uu
	{0x011722, 0x011725},

	// Ahom Vowel Sign Aw      ..Ahom Sign Killer
	{0x011727, 0x01172B},

	// Dogra Vowel Sign U      ..Dogra Sign Anusvara
	{0x01182F, 0x011837},

	// Dogra Sign Virama       ..Dogra Sign Nukta
	{0x011839, 0x01183A},

	// (nil)                   ..(nil)
	{0x01193B, 0x01193C},

	// (nil)                   ..(nil)
	{0x01193E, 0x01193E},

	// (nil)                   ..(nil)
	{0x011943, 0x011943},

	// Nandinagari Vowel Sign U..Nandinagari Vowel Sign V
	{0x0119D4, 0x0119D7},

	// Nandinagari Vowel Sign E..Nandinagari Vowel Sign A
	{0x0119DA, 0x0119DB},

	// Nandinagari Sign Virama ..Nandinagari Sign Virama
	{0x0119E0, 0x0119E0},

	// Zanabazar Square Vowel S..Zanabazar Square Vowel L
	{0x011A01, 0x011A0A},

	// Zanabazar Square Final C..Zanabazar Square Sign An
	{0x011A33, 0x011A38},

	// Zanabazar Square Cluster..Zanabazar Square Cluster
	{0x011A3B, 0x011A3E},

	// Zanabazar Square Subjoin..Zanabazar Square Subjoin
	{0x011A47, 0x011A47},

	// Soyombo Vowel Sign I    ..Soyombo Vowel Sign Oe
	{0x011A51, 0x011A56},

	// Soyombo Vowel Sign Vocal..Soyombo Vowel Length Mar
	{0x011A59, 0x011A5B},

	// Soyombo Final Consonant ..Soyombo Sign Anusvara
	{0x011A8A, 0x011A96},

	// Soyombo Gemination Mark ..Soyombo Subjoiner
	{0x011A98, 0x011A99},

	// Bhaiksuki Vowel Sign I  ..Bhaiksuki Vowel Sign Voc
	{0x011C30, 0x011C36},

	// Bhaiksuki Vowel Sign E  ..Bhaiksuki Sign Anusvara
	{0x011C38, 0x011C3D},

	// Bhaiksuki Sign Virama   ..Bhaiksuki Sign Virama
	{0x011C3F, 0x011C3F},

	// Marchen Subjoined Letter..Marchen Subjoined Letter
	{0x011C92, 0x011CA7},

	// Marchen Subjoined Letter..Marchen Vowel Sign Aa
	{0x011CAA, 0x011CB0},

	// Marchen Vowel Sign U    ..Marchen Vowel Sign E
	{0x011CB2, 0x011CB3},

	// Marchen Sign Anusvara   ..Marchen Sign Candrabindu
	{0x011CB5, 0x011CB6},

	// Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
	{0x011D31, 0x011D36},

	// Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
	{0x011D3A, 0x011D3A},

	// Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
	{0x011D3C, 0x011D3D},

	// Masaram Gondi Vowel Sign..Masaram Gondi Virama
	{0x011D3F, 0x011D45},

	// Masaram Gondi Ra-kara   ..Masaram Gondi Ra-kara
	{0x011D47, 0x011D47},

	// Gunjala Gondi Vowel Sign..Gunjala Gondi Vowel Sign
	{0x011D90, 0x011D91},

	// Gunjala Gondi Sign Anusv..Gunjala Gondi Sign Anusv
	{0x011D95, 0x011D95},

	// Gunjala Gondi Virama    ..Gunjala Gondi Virama
	{0x011D97, 0x011D97},

	// Makasar Vowel Sign I    ..Makasar Vowel Sign U
	{0x011EF3, 0x011EF4},

	// Bassa Vah Combining High..Bassa Vah Combining High
	{0x016AF0, 0x016AF4},

	// Pahawh Hmong Mark Cim Tu..Pahawh Hmong Mark Cim Ta
	{0x016B30, 0x016B36},

	// Miao Sign Consonant Modi..Miao Sign Consonant Modi
	{0x016F4F, 0x016F4F},

	// Miao Tone Right         ..Miao Tone Below
	{0x016F8F, 0x016F92},

	// (nil)                   ..(nil)
	{0x016FE4, 0x016FE4},

	// Duployan Thick Letter Se..Duployan Double Mark
	{0x01BC9D, 0x01BC9E},

	// Musical Symbol Combining..Musical Symbol Combining
	{0x01D167, 0x01D169},

	// Musical Symbol Combining..Musical Symbol Combining
	{0x01D17B, 0x01D182},

	// Musical Symbol Combining..Musical Symbol Combining
	{0x01D185, 0x01D18B},

	// Musical Symbol Combining..Musical Symbol Combining
	{0x01D1AA, 0x01D1AD},

	// Combining Greek Musical ..Combining Greek Musical
	{0x01D242, 0x01D244},

	// Signwriting Head Rim    ..Signwriting Air Sucking
	{0x01DA00, 0x01DA36},

	// Signwriting Mouth Closed..Signwriting Excitement
	{0x01DA3B, 0x01DA6C},

	// Signwriting Upper Body T..Signwriting Upper Body T
	{0x01DA75, 0x01DA75},

	// Signwriting Location Hea..Signwriting Location Hea
	{0x01DA84, 0x01DA84},

	// Signwriting Fill Modifie..Signwriting Fill Modifie
	{0x01DA9B, 0x01DA9F},

	// Signwriting Rotation Mod..Signwriting Rotation Mod
	{0x01DAA1, 0x01DAAF},

	// Combining Glagolitic Let..Combining Glagolitic Let
	{0x01E000, 0x01E006},

	// Combining Glagolitic Let..Combining Glagolitic Let
	{0x01E008, 0x01E018},

	// Combining Glagolitic Let..Combining Glagolitic Let
	{0x01E01B, 0x01E021},

	// Combining Glagolitic Let..Combining Glagolitic Let
	{0x01E023, 0x01E024},

	// Combining Glagolitic Let..Combining Glagolitic Let
	{0x01E026, 0x01E02A},

	// Nyiakeng Puachue Hmong T..Nyiakeng Puachue Hmong T
	{0x01E130, 0x01E136},

	// Wancho Tone Tup         ..Wancho Tone Koini
	{0x01E2EC, 0x01E2EF},

	// Mende Kikakui Combining ..Mende Kikakui Combining
	{0x01E8D0, 0x01E8D6},

	// Adlam Alif Lengthener   ..Adlam Nukta
	{0x01E944, 0x01E94A},

	// Variation Selector-17   ..Variation Selector-256
	{0x0E0100, 0x0E01EF},
];

/*
 * https://github.com/jquast/wcwidth/blob/master/wcwidth/table_wide.py
 * at commit b29897e5a1b403a0e36f7fc991614981cbc42475 (2020-07-14):
 */
private static immutable .width_interval[] WIDE_EASTASIAN =
[
	// Hangul Choseong Kiyeok  ..Hangul Choseong Filler
	{0x001100, 0x00115F},

	// Watch                   ..Hourglass
	{0x00231A, 0x00231B},

	// Left-pointing Angle Brac..Right-pointing Angle Bra
	{0x002329, 0x00232A},

	// Black Right-pointing Dou..Black Down-pointing Doub
	{0x0023E9, 0x0023EC},

	// Alarm Clock             ..Alarm Clock
	{0x0023F0, 0x0023F0},

	// Hourglass With Flowing S..Hourglass With Flowing S
	{0x0023F3, 0x0023F3},

	// White Medium Small Squar..Black Medium Small Squar
	{0x0025FD, 0x0025FE},

	// Umbrella With Rain Drops..Hot Beverage
	{0x002614, 0x002615},

	// Aries                   ..Pisces
	{0x002648, 0x002653},

	// Wheelchair Symbol       ..Wheelchair Symbol
	{0x00267F, 0x00267F},

	// Anchor                  ..Anchor
	{0x002693, 0x002693},

	// High Voltage Sign       ..High Voltage Sign
	{0x0026A1, 0x0026A1},

	// Medium White Circle     ..Medium Black Circle
	{0x0026AA, 0x0026AB},

	// Soccer Ball             ..Baseball
	{0x0026BD, 0x0026BE},

	// Snowman Without Snow    ..Sun Behind Cloud
	{0x0026C4, 0x0026C5},

	// Ophiuchus               ..Ophiuchus
	{0x0026CE, 0x0026CE},

	// No Entry                ..No Entry
	{0x0026D4, 0x0026D4},

	// Church                  ..Church
	{0x0026EA, 0x0026EA},

	// Fountain                ..Flag In Hole
	{0x0026F2, 0x0026F3},

	// Sailboat                ..Sailboat
	{0x0026F5, 0x0026F5},

	// Tent                    ..Tent
	{0x0026FA, 0x0026FA},

	// Fuel Pump               ..Fuel Pump
	{0x0026FD, 0x0026FD},

	// White Heavy Check Mark  ..White Heavy Check Mark
	{0x002705, 0x002705},

	// Raised Fist             ..Raised Hand
	{0x00270A, 0x00270B},

	// Sparkles                ..Sparkles
	{0x002728, 0x002728},

	// Cross Mark              ..Cross Mark
	{0x00274C, 0x00274C},

	// Negative Squared Cross M..Negative Squared Cross M
	{0x00274E, 0x00274E},

	// Black Question Mark Orna..White Exclamation Mark O
	{0x002753, 0x002755},

	// Heavy Exclamation Mark S..Heavy Exclamation Mark S
	{0x002757, 0x002757},

	// Heavy Plus Sign         ..Heavy Division Sign
	{0x002795, 0x002797},

	// Curly Loop              ..Curly Loop
	{0x0027B0, 0x0027B0},

	// Double Curly Loop       ..Double Curly Loop
	{0x0027BF, 0x0027BF},

	// Black Large Square      ..White Large Square
	{0x002B1B, 0x002B1C},

	// White Medium Star       ..White Medium Star
	{0x002B50, 0x002B50},

	// Heavy Large Circle      ..Heavy Large Circle
	{0x002B55, 0x002B55},

	// Cjk Radical Repeat      ..Cjk Radical Rap
	{0x002E80, 0x002E99},

	// Cjk Radical Choke       ..Cjk Radical C-simplified
	{0x002E9B, 0x002EF3},

	// Kangxi Radical One      ..Kangxi Radical Flute
	{0x002F00, 0x002FD5},

	// Ideographic Description ..Ideographic Description
	{0x002FF0, 0x002FFB},

	// Ideographic Space       ..Ideographic Variation In
	{0x003000, 0x00303E},

	// Hiragana Letter Small A ..Hiragana Letter Small Ke
	{0x003041, 0x003096},

	// Combining Katakana-hirag..Katakana Digraph Koto
	{0x003099, 0x0030FF},

	// Bopomofo Letter B       ..Bopomofo Letter Nn
	{0x003105, 0x00312F},

	// Hangul Letter Kiyeok    ..Hangul Letter Araeae
	{0x003131, 0x00318E},

	// Ideographic Annotation L..Cjk Stroke Q
	{0x003190, 0x0031E3},

	// Katakana Letter Small Ku..Parenthesized Korean Cha
	{0x0031F0, 0x00321E},

	// Parenthesized Ideograph ..Circled Ideograph Koto
	{0x003220, 0x003247},

	// Partnership Sign        ..(nil)
	{0x003250, 0x004DBF},

	// Cjk Unified Ideograph-4e..Yi Syllable Yyr
	{0x004E00, 0x00A48C},

	// Yi Radical Qot          ..Yi Radical Ke
	{0x00A490, 0x00A4C6},

	// Hangul Choseong Tikeut-m..Hangul Choseong Ssangyeo
	{0x00A960, 0x00A97C},

	// Hangul Syllable Ga      ..Hangul Syllable Hih
	{0x00AC00, 0x00D7A3},

	// Cjk Compatibility Ideogr..(nil)
	{0x00F900, 0x00FAFF},

	// Presentation Form For Ve..Presentation Form For Ve
	{0x00FE10, 0x00FE19},

	// Presentation Form For Ve..Small Full Stop
	{0x00FE30, 0x00FE52},

	// Small Semicolon         ..Small Equals Sign
	{0x00FE54, 0x00FE66},

	// Small Reverse Solidus   ..Small Commercial At
	{0x00FE68, 0x00FE6B},

	// Fullwidth Exclamation Ma..Fullwidth Right White Pa
	{0x00FF01, 0x00FF60},

	// Fullwidth Cent Sign     ..Fullwidth Won Sign
	{0x00FFE0, 0x00FFE6},

	// Tangut Iteration Mark   ..(nil)
	{0x016FE0, 0x016FE4},

	// (nil)                   ..(nil)
	{0x016FF0, 0x016FF1},

	// (nil)                   ..(nil)
	{0x017000, 0x0187F7},

	// Tangut Component-001    ..(nil)
	{0x018800, 0x018CD5},

	// (nil)                   ..(nil)
	{0x018D00, 0x018D08},

	// Katakana Letter Archaic ..Hentaigana Letter N-mu-m
	{0x01B000, 0x01B11E},

	// Hiragana Letter Small Wi..Hiragana Letter Small Wo
	{0x01B150, 0x01B152},

	// Katakana Letter Small Wi..Katakana Letter Small N
	{0x01B164, 0x01B167},

	// Nushu Character-1b170   ..Nushu Character-1b2fb
	{0x01B170, 0x01B2FB},

	// Mahjong Tile Red Dragon ..Mahjong Tile Red Dragon
	{0x01F004, 0x01F004},

	// Playing Card Black Joker..Playing Card Black Joker
	{0x01F0CF, 0x01F0CF},

	// Negative Squared Ab     ..Negative Squared Ab
	{0x01F18E, 0x01F18E},

	// Squared Cl              ..Squared Vs
	{0x01F191, 0x01F19A},

	// Square Hiragana Hoka    ..Squared Katakana Sa
	{0x01F200, 0x01F202},

	// Squared Cjk Unified Ideo..Squared Cjk Unified Ideo
	{0x01F210, 0x01F23B},

	// Tortoise Shell Bracketed..Tortoise Shell Bracketed
	{0x01F240, 0x01F248},

	// Circled Ideograph Advant..Circled Ideograph Accept
	{0x01F250, 0x01F251},

	// Rounded Symbol For Fu   ..Rounded Symbol For Cai
	{0x01F260, 0x01F265},

	// Cyclone                 ..Shooting Star
	{0x01F300, 0x01F320},

	// Hot Dog                 ..Cactus
	{0x01F32D, 0x01F335},

	// Tulip                   ..Baby Bottle
	{0x01F337, 0x01F37C},

	// Bottle With Popping Cork..Graduation Cap
	{0x01F37E, 0x01F393},

	// Carousel Horse          ..Swimmer
	{0x01F3A0, 0x01F3CA},

	// Cricket Bat And Ball    ..Table Tennis Paddle And
	{0x01F3CF, 0x01F3D3},

	// House Building          ..European Castle
	{0x01F3E0, 0x01F3F0},

	// Waving Black Flag       ..Waving Black Flag
	{0x01F3F4, 0x01F3F4},

	// Badminton Racquet And Sh..Paw Prints
	{0x01F3F8, 0x01F43E},

	// Eyes                    ..Eyes
	{0x01F440, 0x01F440},

	// Ear                     ..Videocassette
	{0x01F442, 0x01F4FC},

	// Prayer Beads            ..Down-pointing Small Red
	{0x01F4FF, 0x01F53D},

	// Kaaba                   ..Menorah With Nine Branch
	{0x01F54B, 0x01F54E},

	// Clock Face One Oclock   ..Clock Face Twelve-thirty
	{0x01F550, 0x01F567},

	// Man Dancing             ..Man Dancing
	{0x01F57A, 0x01F57A},

	// Reversed Hand With Middl..Raised Hand With Part Be
	{0x01F595, 0x01F596},

	// Black Heart             ..Black Heart
	{0x01F5A4, 0x01F5A4},

	// Mount Fuji              ..Person With Folded Hands
	{0x01F5FB, 0x01F64F},

	// Rocket                  ..Left Luggage
	{0x01F680, 0x01F6C5},

	// Sleeping Accommodation  ..Sleeping Accommodation
	{0x01F6CC, 0x01F6CC},

	// Place Of Worship        ..Shopping Trolley
	{0x01F6D0, 0x01F6D2},

	// Hindu Temple            ..(nil)
	{0x01F6D5, 0x01F6D7},

	// Airplane Departure      ..Airplane Arriving
	{0x01F6EB, 0x01F6EC},

	// Scooter                 ..(nil)
	{0x01F6F4, 0x01F6FC},

	// Large Orange Circle     ..Large Brown Square
	{0x01F7E0, 0x01F7EB},

	// (nil)                   ..Fencer
	{0x01F90C, 0x01F93A},

	// Wrestlers               ..Goal Net
	{0x01F93C, 0x01F945},

	// First Place Medal       ..(nil)
	{0x01F947, 0x01F978},

	// Face With Pleading Eyes ..(nil)
	{0x01F97A, 0x01F9CB},

	// Standing Person         ..Nazar Amulet
	{0x01F9CD, 0x01F9FF},

	// Ballet Shoes            ..(nil)
	{0x01FA70, 0x01FA74},

	// Drop Of Blood           ..Stethoscope
	{0x01FA78, 0x01FA7A},

	// Yo-yo                   ..(nil)
	{0x01FA80, 0x01FA86},

	// Ringed Planet           ..(nil)
	{0x01FA90, 0x01FAA8},

	// (nil)                   ..(nil)
	{0x01FAB0, 0x01FAB6},

	// (nil)                   ..(nil)
	{0x01FAC0, 0x01FAC2},

	// (nil)                   ..(nil)
	{0x01FAD0, 0x01FAD6},

	// Cjk Unified Ideograph-20..(nil)
	{0x020000, 0x02FFFD},

	// (nil)                   ..(nil)
	{0x030000, 0x03FFFD},
];

pure nothrow @safe @nogc @live
private bool intable(immutable ref .width_interval[] table, size_t table_length, uint c)

	do
	{
		// First quick check for Latin1 etc. characters.
		if (c < table[0].start) {
			return false;
		}

		// Binary search in table.
		size_t bot = 0;
		size_t top = table_length - 1;

		while (top >= bot) {
			size_t mid = (bot + top) / 2;

			if (table[mid].end < c) {
				bot = mid + 1;
			} else if (table[mid].start > c) {
				top = mid - 1;
			} else {
				return true;
			}
		}

		return false;
	}

///
extern (C)
pure nothrow @safe @nogc @live
public int wcwidth(uint ucs)

	out(result)
	{
		assert(result >= -1);
		assert(result <= 2);
	}

	do
	{
		/*
		 * NOTE: created by hand, there isn't anything identifiable other than
		 * general Cf category code to identify these, and some characters in Cf
		 * category code are of non-zero width.
		 */
		if ((ucs == 0) || (ucs == 0x034F) || ((0x200B <= ucs) && (ucs <= 0x200F)) || (ucs == 0x2028) || (ucs == 0x2029) || ((0x202A <= ucs) && (ucs <= 0x202E)) || ((0x2060 <= ucs) && (ucs <= 0x2063))) {
			return 0;
		}

		// C0/C1 control characters.
		if ((ucs < 32) || ((0x007F <= ucs) && (ucs < 0x00A0))) {
			return -1;
		}

		// Combining characters with zero width.
		if (.intable(.ZERO_WIDTH, .ZERO_WIDTH.length, ucs)) {
			return 0;
		}

		return (.intable(.WIDE_EASTASIAN, .WIDE_EASTASIAN.length, ucs)) ? (2) : (1);
	}

unittest
{
	assert(.wcwidth(cast(uint)('a')) == 1);
	assert(.wcwidth(cast(uint)('ö')) == 1);

	// Some wide:
	assert(.wcwidth(cast(uint)('Ａ')) == 2);
	assert(.wcwidth(cast(uint)('Ｂ')) == 2);
	assert(.wcwidth(cast(uint)('Ｃ')) == 2);
	assert(.wcwidth(cast(uint)('中')) == 2);
	assert(.wcwidth(cast(uint)('文')) == 2);
	assert(.wcwidth(cast(uint)(0x679C)) == 2);
	assert(.wcwidth(cast(uint)(0x679D)) == 2);
	assert(.wcwidth(cast(uint)(0x02070E)) == 2);
	assert(.wcwidth(cast(uint)(0x020731)) == 2);

	assert(.wcwidth(cast(uint)(0x11A3)) == 1);

	// Koala emoji.
	assert(.wcwidth(cast(uint)(0x01F428)) == 2);

	// Watch emoji.
	assert(.wcwidth(cast(uint)(0x231A)) == 2);
}
