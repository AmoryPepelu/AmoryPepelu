#!/bin/bash
# chmod a+x push.sh

date_str=`date +"%Y-%m-%d %H:%M:%S"`

git add .

git commit -m "$date_str"

git push
