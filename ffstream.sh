#!/bin/bash
ffmpeg=./bin/ffmpeg
input=$(find movies -name '*.mkv' -print -quit)
subs=$(find movies -name '*.el.srt' -print -quit)

rtmp_url="rtmp://127.0.0.1:1935/dash"
rtmp_key="1234"

libx264_settings="-profile:v high -level 4.1 -framerate 30 -maxrate 5120k -bufsize 5120k -x264-params keyint=90"
scale720p="(iw*sar)*min(1280/(iw*sar)\,720/ih):ih*min(1280/(iw*sar)\,720/ih), pad=1280:720:(1280-iw*min(1280/iw\,720/ih))/2:(720-ih*min(1280/iw\,720/ih))/2"
scale1080p="(iw*sar)*min(1920/(iw*sar)\,1080/ih):ih*min(1920/(iw*sar)\,1080/ih), pad=1920:1080:(1920-iw*min(1920/iw\,1080/ih))/2:(1080-ih*min(1920/iw\,1080/ih))/2"

$ffmpeg -i "$input" -ac 2\
	-c:v libx264 $libx264_settings -tune zerolatency -crf 24 \
	-vf scale="$scale720p",subtitles="$subs":force_style=\'FontSize=26,FontName=Verdana\' \
	-c:a aac -ab 256k \
	-strict experimental \
	-f flv "$rtmp_url"/"$rtmp_key"

