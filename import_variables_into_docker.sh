#!/bin/bash

custom_vars_dir="composer/${1}/data/custom_vars"

if [ ! -d "$custom_vars_dir" ]; then
  mkdir $custom_vars_dir
  echo "Directory custom_vars created."
fi

cp -r ../firebrick_composer-config/* $custom_vars_dir

# cd $custom_vars_dir


for filepath in $(find {$custom_vars_dir/blau,$custom_vars_dir/firebrick,$custom_vars_dir/onyx,$custom_vars_dir/iridium} -maxdepth 1 -type f \( -name '*_prd.json' -o -name '*_tst.json' -o -name '*_dev.json' \)); do

  filename=$(basename "$filepath")
  if [[ "$filename" == *_dev.json ]]; then
    prefix=$(echo "$filename" | sed 's/_dev\.json$//')

    # Read the contents of the original JSON file
    content=$(cat "$filepath")

    # Create the new JSON structure with just the "variable" key
    new_content="{ \"$prefix\": $content }"

    # Overwrite the original file with the new content
    echo "$new_content" > "$filepath"

    echo "Transformed $filename and saved as $filename"
  else
    echo "Skipping $filename"
  fi
done


for filename in $(find {$custom_vars_dir/blau,$custom_vars_dir/firebrick,$custom_vars_dir/onyx,$custom_vars_dir/iridium} -maxdepth 1 -type f -not -name '*_variables_*'); do
  echo "Write prefix in config file $filename..."
  PREFIX=$(basename "${filename}" | cut -d'_' -f1)

  # Extract the first key in the JSON file
  CONFIG_KEY=$(jq -r 'keys[0]' "$filename")

  # Determine the correct sed command based on the OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "2s/\"${CONFIG_KEY}\"/\"${PREFIX}_${CONFIG_KEY}\"/" "$filename"
  else
    sed -i "2s/\"${CONFIG_KEY}\"/\"${PREFIX}_${CONFIG_KEY}\"/" "$filename"
  fi
done


for filename in $(find $custom_vars_dir -type f -name "*.json"); do
  echo "Importing variables file /home/airflow/gcs/data/custom_vars/$filename"
  composer-dev run-airflow-cmd ${1} variables import "/home/airflow/gcs/data/${filename##*/data}"
  # airflow variables import "$filename"
done

# docker-compose run --rm airflow-cli bash -c '
# for filename in $(find custom_vars_dir -type f -name "*.json"); do
#   echo "Importing variables file $filename..."
#   airflow variables import "$filename"
# done
# '