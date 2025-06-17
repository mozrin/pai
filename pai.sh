#!/bin/bash

# Include Configuration Paramters
source pai_config.sh

# --- Section: Initialize Output File
> "$OUTPUT_FILE"

# --- Section: Add the global prompt
echo -e "--- AI Primary Prompt ---" >> "$OUTPUT_FILE"
cat "$PROMPT_FILE" >> "$OUTPUT_FILE"
echo -e "\n" >> "$OUTPUT_FILE"

# --- Section: Add the session prompt
echo -e "--- AI Details Prompt ---" >> "$OUTPUT_FILE"
cat "$DETAILS_FILE" >> "$OUTPUT_FILE"
echo -e "\n" >> "$OUTPUT_FILE"

# --- Section 1: Folder Structure (containing .dart files within lib/) ---
echo "--- Folder Structure ---" >> "$OUTPUT_FILE"

# Exclude common build/OS/dependency folders that are not part of the source code logic

# Check if the 'tree' command is available
if command -v tree &> /dev/null; then
  IFS='|' read -ra FOLDERS <<< "$ROOT_FOLDERS"
  for ROOT_FOLDER in "${FOLDERS[@]}"; do
    tree -F -P "*.dart" -I "$EXCLUDE_DIRS" "$ROOT_FOLDER" >> "$OUTPUT_FILE"
    echo "------------------------" >> "$OUTPUT_FILE"
  done
else
  echo "Warning: 'tree' command not found. Listing directories containing .dart files instead." >> "$OUTPUT_FILE"
  IFS='|' read -ra FOLDERS <<< "$ROOT_FOLDERS"
  for ROOT_FOLDER in "${FOLDERS[@]}"; do
    find "$ROOT_FOLDER" -type f | grep -E "\.($INCLUDE_EXTS)$" | xargs -I {} dirname {} | sort -u | sed 's|^|./|' >> "$OUTPUT_FILE"
  done
fi
echo -e "\n\n" >> "$OUTPUT_FILE"

# --- Section 2: Concatenated File Contents with Headers ---
echo "--- Baseline File Contents ---" >> "$OUTPUT_FILE"
echo -e "\n\n" >> "$OUTPUT_FILE"

IFS='|' read -ra FOLDERS <<< "$ROOT_FOLDERS"
for ROOT_FOLDER in "${FOLDERS[@]}"; do
  find "$ROOT_FOLDER" -type f | grep -E "\.($INCLUDE_EXTS)$" | grep -Ev "$EXCLUDE_DIRS" | while read -r file; do
    filename=$(basename "$file")
    if ! echo "$filename" | grep -Eq "$EXCLUDE_FILES"; then
      echo "# $file " >> "$OUTPUT_FILE"
      sed '/\/\*/,/\*\//d' "$file" | sed 's|//.*||' | sed '/^use /{ /Has/!d }' | sed 's/^[ \t]*//' >> "$OUTPUT_FILE"
      echo -e "\n\n" >> "$OUTPUT_FILE"
    fi
  done
done

echo "Generated $OUTPUT_FILE"
