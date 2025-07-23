#!/bin/bash

# Script to rename .ovpn files from <country>.protonvpn.udp.ovpn to <country>.conf
# Converts 2-letter country codes to full country names
# Usage: ./rename_ovpn.sh [directory]

# Function to convert 2-letter country codes to full names
get_country_name() {
    local code="$1"
    case "${code,,}" in  # Convert to lowercase for matching
        "ad") echo "andorra" ;;
        "ae") echo "united-arab-emirates" ;;
        "af") echo "afghanistan" ;;
        "ag") echo "antigua-and-barbuda" ;;
        "ai") echo "anguilla" ;;
        "al") echo "albania" ;;
        "am") echo "armenia" ;;
        "ao") echo "angola" ;;
        "aq") echo "antarctica" ;;
        "ar") echo "argentina" ;;
        "as") echo "american-samoa" ;;
        "at") echo "austria" ;;
        "au") echo "australia" ;;
        "aw") echo "aruba" ;;
        "ax") echo "aland-islands" ;;
        "az") echo "azerbaijan" ;;
        "ba") echo "bosnia-and-herzegovina" ;;
        "bb") echo "barbados" ;;
        "bd") echo "bangladesh" ;;
        "be") echo "belgium" ;;
        "bf") echo "burkina-faso" ;;
        "bg") echo "bulgaria" ;;
        "bh") echo "bahrain" ;;
        "bi") echo "burundi" ;;
        "bj") echo "benin" ;;
        "bl") echo "saint-barthelemy" ;;
        "bm") echo "bermuda" ;;
        "bn") echo "brunei" ;;
        "bo") echo "bolivia" ;;
        "bq") echo "bonaire" ;;
        "br") echo "brazil" ;;
        "bs") echo "bahamas" ;;
        "bt") echo "bhutan" ;;
        "bv") echo "bouvet-island" ;;
        "bw") echo "botswana" ;;
        "by") echo "belarus" ;;
        "bz") echo "belize" ;;
        "ca") echo "canada" ;;
        "cc") echo "cocos-islands" ;;
        "cd") echo "democratic-republic-congo" ;;
        "cf") echo "central-african-republic" ;;
        "cg") echo "republic-congo" ;;
        "ch") echo "switzerland" ;;
        "ci") echo "ivory-coast" ;;
        "ck") echo "cook-islands" ;;
        "cl") echo "chile" ;;
        "cm") echo "cameroon" ;;
        "cn") echo "china" ;;
        "co") echo "colombia" ;;
        "cr") echo "costa-rica" ;;
        "cu") echo "cuba" ;;
        "cv") echo "cape-verde" ;;
        "cw") echo "curacao" ;;
        "cx") echo "christmas-island" ;;
        "cy") echo "cyprus" ;;
        "cz") echo "czech-republic" ;;
        "de") echo "germany" ;;
        "dj") echo "djibouti" ;;
        "dk") echo "denmark" ;;
        "dm") echo "dominica" ;;
        "do") echo "dominican-republic" ;;
        "dz") echo "algeria" ;;
        "ec") echo "ecuador" ;;
        "ee") echo "estonia" ;;
        "eg") echo "egypt" ;;
        "eh") echo "western-sahara" ;;
        "er") echo "eritrea" ;;
        "es") echo "spain" ;;
        "et") echo "ethiopia" ;;
        "fi") echo "finland" ;;
        "fj") echo "fiji" ;;
        "fk") echo "falkland-islands" ;;
        "fm") echo "micronesia" ;;
        "fo") echo "faroe-islands" ;;
        "fr") echo "france" ;;
        "ga") echo "gabon" ;;
        "gb") echo "united-kingdom" ;;
        "gd") echo "grenada" ;;
        "ge") echo "georgia" ;;
        "gf") echo "french-guiana" ;;
        "gg") echo "guernsey" ;;
        "gh") echo "ghana" ;;
        "gi") echo "gibraltar" ;;
        "gl") echo "greenland" ;;
        "gm") echo "gambia" ;;
        "gn") echo "guinea" ;;
        "gp") echo "guadeloupe" ;;
        "gq") echo "equatorial-guinea" ;;
        "gr") echo "greece" ;;
        "gs") echo "south-georgia" ;;
        "gt") echo "guatemala" ;;
        "gu") echo "guam" ;;
        "gw") echo "guinea-bissau" ;;
        "gy") echo "guyana" ;;
        "hk") echo "hong-kong" ;;
        "hm") echo "heard-island" ;;
        "hn") echo "honduras" ;;
        "hr") echo "croatia" ;;
        "ht") echo "haiti" ;;
        "hu") echo "hungary" ;;
        "id") echo "indonesia" ;;
        "ie") echo "ireland" ;;
        "il") echo "israel" ;;
        "im") echo "isle-of-man" ;;
        "in") echo "india" ;;
        "io") echo "british-indian-ocean-territory" ;;
        "iq") echo "iraq" ;;
        "ir") echo "iran" ;;
        "is") echo "iceland" ;;
        "it") echo "italy" ;;
        "je") echo "jersey" ;;
        "jm") echo "jamaica" ;;
        "jo") echo "jordan" ;;
        "jp") echo "japan" ;;
        "ke") echo "kenya" ;;
        "kg") echo "kyrgyzstan" ;;
        "kh") echo "cambodia" ;;
        "ki") echo "kiribati" ;;
        "km") echo "comoros" ;;
        "kn") echo "saint-kitts-and-nevis" ;;
        "kp") echo "north-korea" ;;
        "kr") echo "south-korea" ;;
        "kw") echo "kuwait" ;;
        "ky") echo "cayman-islands" ;;
        "kz") echo "kazakhstan" ;;
        "la") echo "laos" ;;
        "lb") echo "lebanon" ;;
        "lc") echo "saint-lucia" ;;
        "li") echo "liechtenstein" ;;
        "lk") echo "sri-lanka" ;;
        "lr") echo "liberia" ;;
        "ls") echo "lesotho" ;;
        "lt") echo "lithuania" ;;
        "lu") echo "luxembourg" ;;
        "lv") echo "latvia" ;;
        "ly") echo "libya" ;;
        "ma") echo "morocco" ;;
        "mc") echo "monaco" ;;
        "md") echo "moldova" ;;
        "me") echo "montenegro" ;;
        "mf") echo "saint-martin" ;;
        "mg") echo "madagascar" ;;
        "mh") echo "marshall-islands" ;;
        "mk") echo "north-macedonia" ;;
        "ml") echo "mali" ;;
        "mm") echo "myanmar" ;;
        "mn") echo "mongolia" ;;
        "mo") echo "macao" ;;
        "mp") echo "northern-mariana-islands" ;;
        "mq") echo "martinique" ;;
        "mr") echo "mauritania" ;;
        "ms") echo "montserrat" ;;
        "mt") echo "malta" ;;
        "mu") echo "mauritius" ;;
        "mv") echo "maldives" ;;
        "mw") echo "malawi" ;;
        "mx") echo "mexico" ;;
        "my") echo "malaysia" ;;
        "mz") echo "mozambique" ;;
        "na") echo "namibia" ;;
        "nc") echo "new-caledonia" ;;
        "ne") echo "niger" ;;
        "nf") echo "norfolk-island" ;;
        "ng") echo "nigeria" ;;
        "ni") echo "nicaragua" ;;
        "nl") echo "netherlands" ;;
        "no") echo "norway" ;;
        "np") echo "nepal" ;;
        "nr") echo "nauru" ;;
        "nu") echo "niue" ;;
        "nz") echo "new-zealand" ;;
        "om") echo "oman" ;;
        "pa") echo "panama" ;;
        "pe") echo "peru" ;;
        "pf") echo "french-polynesia" ;;
        "pg") echo "papua-new-guinea" ;;
        "ph") echo "philippines" ;;
        "pk") echo "pakistan" ;;
        "pl") echo "poland" ;;
        "pm") echo "saint-pierre-and-miquelon" ;;
        "pn") echo "pitcairn" ;;
        "pr") echo "puerto-rico" ;;
        "ps") echo "palestine" ;;
        "pt") echo "portugal" ;;
        "pw") echo "palau" ;;
        "py") echo "paraguay" ;;
        "qa") echo "qatar" ;;
        "re") echo "reunion" ;;
        "ro") echo "romania" ;;
        "rs") echo "serbia" ;;
        "ru") echo "russia" ;;
        "rw") echo "rwanda" ;;
        "sa") echo "saudi-arabia" ;;
        "sb") echo "solomon-islands" ;;
        "sc") echo "seychelles" ;;
        "sd") echo "sudan" ;;
        "se") echo "sweden" ;;
        "sg") echo "singapore" ;;
        "sh") echo "saint-helena" ;;
        "si") echo "slovenia" ;;
        "sj") echo "svalbard-and-jan-mayen" ;;
        "sk") echo "slovakia" ;;
        "sl") echo "sierra-leone" ;;
        "sm") echo "san-marino" ;;
        "sn") echo "senegal" ;;
        "so") echo "somalia" ;;
        "sr") echo "suriname" ;;
        "ss") echo "south-sudan" ;;
        "st") echo "sao-tome-and-principe" ;;
        "sv") echo "el-salvador" ;;
        "sx") echo "sint-maarten" ;;
        "sy") echo "syria" ;;
        "sz") echo "eswatini" ;;
        "tc") echo "turks-and-caicos-islands" ;;
        "td") echo "chad" ;;
        "tf") echo "french-southern-territories" ;;
        "tg") echo "togo" ;;
        "th") echo "thailand" ;;
        "tj") echo "tajikistan" ;;
        "tk") echo "tokelau" ;;
        "tl") echo "timor-leste" ;;
        "tm") echo "turkmenistan" ;;
        "tn") echo "tunisia" ;;
        "to") echo "tonga" ;;
        "tr") echo "turkey" ;;
        "tt") echo "trinidad-and-tobago" ;;
        "tv") echo "tuvalu" ;;
        "tw") echo "taiwan" ;;
        "tz") echo "tanzania" ;;
        "ua") echo "ukraine" ;;
        "ug") echo "uganda" ;;
        "um") echo "united-states-minor-outlying-islands" ;;
        "us") echo "united-states" ;;
        "uy") echo "uruguay" ;;
        "uz") echo "uzbekistan" ;;
        "va") echo "vatican-city" ;;
        "vc") echo "saint-vincent-and-the-grenadines" ;;
        "ve") echo "venezuela" ;;
        "vg") echo "british-virgin-islands" ;;
        "vi") echo "us-virgin-islands" ;;
        "vn") echo "vietnam" ;;
        "vu") echo "vanuatu" ;;
        "wf") echo "wallis-and-futuna" ;;
        "ws") echo "samoa" ;;
        "ye") echo "yemen" ;;
        "yt") echo "mayotte" ;;
        "za") echo "south-africa" ;;
        "zm") echo "zambia" ;;
        "zw") echo "zimbabwe" ;;
        *) echo "$code" ;; 
    esac
}

# Set directory (use current directory if not specified)
DIR="${1:-.}"

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist."
    exit 1
fi

# Change to the specified directory
cd "$DIR" || exit 1

it=0

# Find and rename all .ovpn files matching the pattern
for file in *.protonvpn.udp.ovpn; do
    if [ ! -f "$file" ]; then
        echo "No .ovpn files found matching pattern '*.protonvpn.udp.ovpn'"
        exit 0
    fi
    
    # Extract country name (everything before first dot)
    country_raw=$(echo "$file" | cut -d'.' -f1)
    
    # Check if it's a 2-letter code and convert to full name
    if [[ ${#country_raw} -eq 2 ]]; then
        country=$(get_country_name "$country_raw")
        echo "Converting 2-letter code '$country_raw' to '$country'"
    else
        country="$country_raw"
    fi
    
    new_name="${country}.conf"
    
    if mv "$file" "$new_name"; then
        echo "Renamed: $file → $new_name"
        ((it++))
    else
        echo "Error: Failed to rename $file"
    fi
done

echo ""
echo "Renamed $it file(s) successfully."