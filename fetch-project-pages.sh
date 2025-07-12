#!/bin/bash

set -e
PROPERTIES_FILE="projects.properties"
CONTENT_DIR="content"

check_properties_file() {
    local prop_file="$1"
    if [ ! -f "$prop_file" ]; then
        echo "Error: Properties file '$prop_file' not found."
        exit 1
    fi
}

fetch_content() {
    local url="$1"
    local target_path="$2"

    echo "➡️ Fetching $url into $target_path" 
    mkdir -p "$(dirname "$target_path")"
    if ! curl -fsSL "$url" -o "$target_path"; then
        echo "❌ Failed to fetch $url"
        exit 1
    fi
}

apply_hugo_front_matter() {
    local file_path="$1"
    local target_path="$2"

    local title=$(basename "$file_path" .md | sed -E 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr(tolower($i),2)}1')

    {
        echo "---"
        echo "title: \"$title\""
        echo "draft: false"
        echo "---"
        cat "$target_path"
    } >"$target_path.tmp"
    mv "$target_path.tmp" "$target_path"
}

transform_image_paths() {
    local markdown_file="$1"
    local original_url="$2"
    local base_raw_url=$(echo "$original_url" | sed -E 's/(https:\/\/raw.githubusercontent.com\/[^\/]+\/[^\/]+\/[^\/]+)\/.*/\1\//')
    local temp_file=$(mktemp)

    while IFS= read -r line; do
        if [[ "$line" == *"!["*"]("*")"* ]]; then
            local alt_text_part="${line#*![}"
            local alt_text="${alt_text_part%%]*}"

            local url_part="${line#*]\(}"
            local image_url="${url_part%%)*}"

            if [[ -n "$image_url" && ! "$image_url" == http://* && ! "$image_url" == https://* ]]; then
                local new_absolute_url="${base_raw_url}${image_url}"

                local old_image_tag="![${alt_text}](${image_url})"
                local new_image_tag="![${alt_text}](${new_absolute_url})"

                local transformed_line="${line//"$old_image_tag"/"$new_image_tag"}"

                echo "$transformed_line" >> "$temp_file"
            else
                echo "$line" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$markdown_file"

    mv "$temp_file" "$markdown_file"
}

echo "Starting to fetch README files from '$PROPERTIES_FILE'..."

check_properties_file "$PROPERTIES_FILE"

while IFS='' read -r line || [[ -n "$line" ]]; do
    cleaned_line=$(echo "$line" | tr -d '\r' | xargs)

    if [[ "$cleaned_line" =~ ^#.* ]] || [[ -z "$cleaned_line" ]]; then
        continue
    fi

    FILE_PATH=$(echo "$cleaned_line" | sed -E 's/([^=]+)=.*/\1/')
    URL=$(echo "$cleaned_line" | sed -E 's/[^=]+=(.*)/\1/')

    FILE_PATH=$(echo "$FILE_PATH" | xargs)
    URL=$(echo "$URL" | xargs)

    TARGET_PATH="$CONTENT_DIR/$FILE_PATH"

    fetch_content "$URL" "$TARGET_PATH"

    transform_image_paths "$TARGET_PATH" "$URL"

    if ! grep -q "^---" "$TARGET_PATH"; then
        apply_hugo_front_matter "$FILE_PATH" "$TARGET_PATH"
    fi

done < "$PROPERTIES_FILE"

echo "✅ All files fetched and processed successfully."