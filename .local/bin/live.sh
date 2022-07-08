#!/bin/sh


ffmpeg -f alsa -i default -f x11grab -framerate 30 -video_size 3840x2160 \
-i :0.0+0,0 -c:v libx264 -preset ultrafast -b:v 13984k -maxrate 13984k -bufsize 6000k \
-pix_fmt yuv420p -g 60 -c:a aac -b:a 192k -ar 44100 \
-f flv rtmp://live-vie.twitch.tv/app/live_530914772_j8WJ4KSQzuSE9TwCea51sNDEQb4j8K
