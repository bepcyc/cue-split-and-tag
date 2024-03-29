#!/bin/bash
# split image file (flac, ape, wav, etc.) according to cue-file

if [ -f "$1" ]; then
    i=0
    for cuefile in *.cue; do
        i=$(($i + 1))
    done
    if [ $i -eq 1 ]; then
        # precies 1 cuesheet gevonden
        if grep -q "INDEX 01 00:00:00" *.cue ; then
            nice shntool split -t "%n %t" -f *.cue "$1"
        else
            echo "The first track has a pre-gap. Shntool will cut that off and put it in a seperate file."
            echo "You don't want that. Please modify the cuesheet from:"
            grep -m1 "INDEX 00" *.cue
            grep -m1 "INDEX 01" *.cue
            echo "to:"
            echo "    INDEX 01 00:00:00"
            exit 1
        fi
    elif [ $i -eq 0 ]; then
        echo "No cuesheet found in the current directory."
        exit 1
    elif [ $i -gt 1 ]; then
        echo "$i cuesheets found in the current directory. Please remove the superfluous cuesheets."
        exit 1
    fi
else
    echo "Split image file (flac, ape, wav, etc.) according to cue-file."
    echo "Output files are in FLAC."
    echo "Usage: `basename $0` <image-file>"
    exit 1
fi

echo
album=`grep -m 1 TITLE *.cue | cut -d\" -f2`
artist=`grep -m 1 PERFORMER *.cue | cut -d\" -f2`

for file in [0-9]*.wav; do
    echo -n "Encoding [$file] --> "
    echo -n "[$file.flac] " | sed -e  "s/.wav//"
    
    if [[ ${file:0:1} == 0 ]] ; then
        tracknr=${file:1:1}
    else
        tracknr=${file:0:2}
    fi
    title=`echo ${file:2} | sed -e "s/.wav$//"`
    
    nice flac -f -s -T "artist=$artist" -T "album=$album" -T "title=$title" \
    -T "tracknumber=$tracknr" "$file" && rm "$file" && echo -n ": OK"
    echo
done

echo
rm -i "$1"
