#!/bin/sh
# (C) Andrew Brock 2017
# GPLv3 or later

export BASEDIR=`readlink -f $(dirname $0)`
RUN="sh -vc"
#RUN="echo"
find ./ -name '*.log' -print0 | xargs -n 1 -0 -I FILE $RUN '
  export fname=`basename "FILE"` &&
  cd `dirname "FILE"` &&
  pwd && echo $fname && 
  mv "${fname}" "${fname}.old" &&
  $BASEDIR/augment_timestamps.pl "${fname}.old" > "${fname}" &&
  $BASEDIR/explode.pl "${fname}" &&
  mv "${fname}.old" "$fname"'
