#!/bin/sh

ratpoison -c echo "KILL ALL FFMPEG"

PID="ps -ef | grep ffmpeg"

kill -9 $PID
