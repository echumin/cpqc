#!/bin/bash

# This is the directory that contains the png files to compile
PNG_DIR="/N/project/HCPaging/iadrc-bids/derivatives/connQC"
FIG_STR="ses-1_3-subcort_vols.png"


cd "$PNG_DIR"

# Start building the HTML code
html="<html>\n  <table>"

# Iterate over files in the directory
for file in *; do
  # Check if the file contains the matching substring
  if [[ $file == *"$FIG_STR"* ]]; then
    # Generate HTML code for each matching file
    html+="\n    <tr>\n      <td><a href=\"file:$file\"><img src=\"$file\"></a></td>\n    </tr>"
  fi
done

# Finish building the HTML code
html+="\n  </table>\n</html>"

# Write the generated HTML code to index.html
echo -e "$html" > index_subcort_ses1.html

echo "HTML code has been written to index.html"
