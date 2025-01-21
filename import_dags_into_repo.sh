#!/bin/bash

# rsync -av --exclude='__pycache__' ../firebrick_composer/plugins/ composer/"${1}"/plugins

source_path="../firebrick_composer/dags"
target_path="composer/${1}/dags"



#for filepath in $(find $source_path -maxdepth 2 -type f \( -name '*.py'\ -a -not -name '*powerbi*' -a -not -name '*pubsub*' -a -not -name '*pub_sub*' \)); do
for filepath in $(find $source_path -maxdepth 2 -type f \
\( -name '*.py' -a -not -name '*powerbi*' \
-a -not -name '*pubsub*' \
-a -not -name '*pub_sub*' \
-a -not -name '*filetransfer*' \
-a -not -name '*hotspot_export*' \
 \)); do
    echo "copy $filepath"

    target_file=$target_path${filepath#*dags}
    target_dir=$(dirname $target_file)
    
    mkdir -p $target_dir
    cp -r $filepath $target_file
done