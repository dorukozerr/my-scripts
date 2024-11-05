#!/bin/zsh

custom_grep() {
    local search_term
    local file_types
    local exclude_dirs
    local grep_cmd="grep -rn"

    # Prompt for search term
    echo -n "Enter search term: "
    read search_term

    # Prompt for file types
    echo -n "File types to search (comma-separated, press enter for default js,jsx,ts,tsx): "
    read file_types
    if [[ -z "$file_types" ]]; then
        file_types="js,jsx,ts,tsx"
    fi

    # Prompt for directories to exclude
    echo -n "Directories to exclude (comma-separated, press enter for default node_modules,build,dist,.next): "
    read exclude_dirs
    if [[ -z "$exclude_dirs" ]]; then
        exclude_dirs="node_modules,build,dist,.next"
    fi

    # Build the grep command
    grep_cmd+=" $search_term . -C 0 --include=\*.{${file_types}} --color=auto --exclude-dir={${exclude_dirs}}"

    # Execute the grep command
    echo "Executing: $grep_cmd"
    eval "$grep_cmd"

    # Check if any results were found
    if [ $? -ne 0 ]; then
        echo "No matches found for '$search_term'."
    fi
}

custom_grep
