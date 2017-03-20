#!/bin/sh

export BASEDIR=`readlink -f $(dirname $0)`
RUN="sh -vc"
#RUN="echo"
find ./ -name '*.log' | xargs -0 -d\\n -I FILE $RUN '
  export fname=`basename 'FILE'` &&
  cd `dirname 'FILE'` &&
  mv "${fname}" "${fname}.old" &&
  $BASEDIR/augment_timestamps.pl "${fname}.old" > "${fname}" &&
  $BASEDIR/explode.pl "${fname}" &&
  mv "${fname}.old" "$fname"'
