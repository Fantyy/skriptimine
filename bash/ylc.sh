#!/bin/bash
#
# Gert Vaikre A21
# Võtab YouTube video URL'i argumendina või (argumendi puudumisel)
# clipboardist ja mängib seda lokaalses pleieris.
#
# Kasutatakse xcmenu clipboard manageri ja VLC pleierit
#

URL=$1
[[ -z $URL ]] && URL=$(xcmenu --get 0)
URL=$(echo $URL | cut -d"&" -f1)

echo $URL | grep "youtube.com/watch?v=" >/dev/null || {
  notify-send -i vlc "\"$URL\" is not a valid YouTube video URL."; exit 1; }

function displayinfo {
    ID=$(echo $URL | cut -d"=" -f2)
    INFO=$(curl -s https://gdata.youtube.com/feeds/api/videos/$ID?v=2)
    TITLE=$(echo $INFO | awk -F'<title>' '{print $2}' | cut -d'<' -f1)
    AUTHOR=$(echo $INFO | awk -F'<name>' '{print $2}' | cut -d'<' -f1)
    notify-send -i vlc "Playing \"$TITLE\" by $AUTHOR"
}

# Taustale, sest muidu peab displayinfo järgi ootama (mõnikord isegi 2-3 sekki)
displayinfo &

vlc $URL
