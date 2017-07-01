#!/bin/bash

# DETECT ENV
SCRIPT=`realpath $0`
ROOT_PATH=`dirname $SCRIPT`
NOW=`date +%Y%m%d%H%M%S`
TMPDIR=$NOW
TMPRANDOM=$RANDOM

TAG=$1 

# SETTINGS
RATIO=1280x1024
enable_just_pixel_sort=0
enable_just_byebyte=1
enable_pixel_and_byebyte=0
enable_random=0
FLIRCK_ENABLE=1
QUEUE_ENABLE=1
VIDEO_ENABLE=1

# PATHS
INPUT_FILES=$ROOT_PATH/files/input/$TMPDIR
OUTPUT_FILES=$ROOT_PATH/files/output/$TMPDIR
TMP_FILES=$ROOT_PATH/files/tmp/$TMPDIR
AUDIO_FILES=$ROOT_PATH/files/audio/
FILE_QUEUE=$ROOT_PATH/files/queue
PROCESSED_FILES=$ROOT_PATH/files/processed
ANIMATIONS=$ROOT_PATH/files/animations
QUEUE=$ROOT_PATH/files/queue

## TOOLS PATH
BYEBYTE=$ROOT_PATH/tools/byebyte/index.js
PIXELSORT=$ROOT_PATH/tools/pixelsort/pixelsort.py
FLIRCK=$ROOT_PATH/tools/flickr/getfLirckpHoto.py



## CREATE TMP INPUT DIRS
rm -fr $ROOT_PATH/files/input/*
rm -fr $ROOT_PATH/files/output/*
rm -fr $ROOT_PATH/files/tmp/*
rm -fr $ROOT_PATH/files/queue/*
mkdir -p $INPUT_FILES
mkdir -p $OUTPUT_FILES
mkdir -p $TMP_FILES



## CLEAN PREVIOUS TMP FILES

clean_tmp_files() {

\rm -fr $TMP_FILES
\rm -fr $OUTPUT_FILES
\rm -fr $INPUT_FILES

}

get_flirck_photos() {

  
  if test $FLIRCK_ENABLE -eq 1
     then

        if [ -z "$TAG" ]; then
          echo "Flirck is enabled as a source stream, please pass a search tag parameter"
          echo " exiting gracefully from the script"
          exit 
        fi

       echo $LOOP
       i=1
        while [ "$i" -le "$LOOP" ]; do
          echo "Getting photo $i of $LOOP about $TAG on flirck"
          python $FLIRCK $TAG $INPUT_FILES/
          sleep 3
          i=$(($i + 1))
        done

     fi


}

get_queue_photos() {

  
  if test $QUEUE_ENABLE -eq 1
     then
     cp -fr $QUEUE/* $INPUT_FILES/
     fi


}

randomize() {
  if test $enable_random -eq 1
     then
      PEAK=`$ROOT_PATH/tools/peak_detect/peak_detect.sh`
      RND_STR=`$ROOT_PATH/tools/random/getString.sh`
      LOOP=$PEAK
      TMP_RND=`echo $RND_STR | cut -d ';' -f 1`
      RND=$(( 100 + $TMP_RND ))
      ANIMATION_DELAY=`echo $RND_STR | cut -d ';' -f 2`
    else
      ## Fall back to defaults
      LOOP=10
      ANIMATION_DELAY=240
      RND=120
     fi
   
     if [ "$LOOP" -gt 15 -a "$LOOP" -lt 1 ]
      then
      LOOP=5
     fi
}


print_settings(){
  echo "  --------------------------------- "
  echo "  PLUGINS"
  echo "      PIXELSORT = $enable_pixel_sort"
  echo "  --------------------------------- "
  echo " SETTINGS"
  echo "          RATIO = $RATIO"
  echo "  DETECTED PEAK = $PEAK"
  echo "     LOOP VALUE = $LOOP"
  echo "RANDOMIZE VALUE = $RND"
  echo "ANIMATION DELAY = $ANIMATION_DELAY"
  echo "  --------------------------------- "  
}

resize() {

      if test "$(ls -A "$OUTPUT_FILES")"; then
          echo "Start resizing files to Ratio: $RATIO"
          else
          echo "Input dir $OUTPUT_FILES is empty... exiting"
          exit
      fi

      for files in $OUTPUT_FILES/*
        do
          # Convert to the size we need
          convert $files -resize $RATIO! $files
        done  

}

create_animation() {

    convert -verbose -delay $ANIMATION_DELAY -loop $LOOP $OUTPUT_FILES/* $ANIMATIONS/$NOW.gif
}

create_video() {

    if test $VIDEO_ENABLE -eq 1
     then
      ffmpeg -i $ANIMATIONS/$NOW.gif -i $AUDIO_FILES/*.wav -c:v libx264 -c:a aac -strict experimental -b:a 192k -shortest $ANIMATIONS/$NOW.mp4
    fi

}


transform() {
    for file in $INPUT_FILES/*
      do

        FILENAME=`echo "$file" | rev | cut -d"/" -f1 | rev`
        echo "Processing $FILENAME file..."

        if test $enable_just_pixel_sort -eq 1
           then   
              # Transforms with pixel_sort
              python3 $PIXELSORT -o $TMP_FILES/$seq-$FILENAME -i random -c $RND $file 
           fi

        if test $enable_just_byebyte -eq 1 
           then  
              # Transforms with byebyte
              node $BYEBYTE -f $file -o $OUTPUT_FILES/$seq-$RANDOM-$FILENAME -t $RND
           fi

        if test $enable_pixel_and_byebyte -eq 1
           then
              # Transforms with both pixel_sort and byebite
              python3 $PIXELSORT -o $TMP_FILES/$seq-$FILENAME -i random -c $RND $file 
              node $BYEBYTE -f $TMP_FILES/$seq-$FILENAME -o $OUTPUT_FILES/$seq-$RANDOM-$FILENAME -t $RND
           fi

      done

}

archiveProcessed() {
mv $INPUT_FILES/* $PROCESSED_FILES/

}

create_sequence() {
  for ((seq=1;seq<=$LOOP;seq++));
    do

       echo "   LOOP $seq de $LOOP  "
       print_settings
       transform
       clear
    done
}



randomize
get_queue_photos
get_flirck_photos
create_sequence
resize
create_animation
create_video
archiveProcessed
clean_tmp_files



