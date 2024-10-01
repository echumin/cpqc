#!/bin/bash

# This is the directory that contains the png files to compile
PNG_DIR="/N/project/adniCONN/iadrc-2024/iadrc-bids/derivatives/connQC-latest/mnireg"
SES="ses-1"
FIG="_2-mni_contour_v2.png"

FIG_STR1="$SES$FIG"
FIG_STR2="${SES}_SAYKIN${FIG}"
FIG_STR3="${SES}_AllFTD${FIG}"


cd "$PNG_DIR"

# Start building the HTML code
html="<html>\n  <table>"

# Iterate over files in the directory
for file in *; do
  # Check if the file contains the matching substring
  if [[ $file == *"$FIG_STR1"* || $file == *"$FIG_STR2"* || $file == *"$FIG_STR3"* ]]; then
    # Generate HTML code for each matching file
    html+="\n    <tr>\n      <td><a href=\"file:$file\"><img src=\"$file\"></a></td>\n    </tr>"
  fi
done

# Finish building the HTML code
html+="\n  </table>\n</html>"

# Write the generated HTML code to index.html
echo -e "$html" > "index_mnireg_$SES.html"

echo "HTML code has been written to index.html"
