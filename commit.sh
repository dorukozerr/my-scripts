#!/bin/bash

# Function to handle Ctrl+C
ctrl_c() {
    echo -e "\nScript interrupted. Exiting..."
    tput cnorm # Restore cursor
    exit 1
}

# Set up the interrupt handler
trap ctrl_c INT

# Array of commit types
types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore")

# Function to display menu and get user selection using arrow keys
select_type() {
    local selected=0
    local key=""
    
    tput civis # Hide cursor

    while true; do
        # Clear screen and print options
        clear
        echo "Select commit type (use arrow keys and press Enter):"
        for i in "${!types[@]}"; do
            if [ $i -eq $selected ]; then
                echo "> ${types[$i]}"
            else
                echo "  ${types[$i]}"
            fi
        done
        
        # Read a single character
        read -s -n 1 key

        case $key in
            A) # Up arrow
                ((selected--))
                if [ $selected -lt 0 ]; then
                    selected=$((${#types[@]} - 1))
                fi
                ;;
            B) # Down arrow
                ((selected++))
                if [ $selected -ge ${#types[@]} ]; then
                    selected=0
                fi
                ;;
            '') # Enter key
                tput cnorm # Restore cursor
                echo
                return $selected
                ;;
        esac
    done
}

# Get commit type
select_type
commit_type=${types[$?]}

# Get optional scope
read -p "Enter scope (optional, press enter to skip): " scope
scope_part=""
if [[ -n $scope ]]; then
    scope_part="($scope)"
fi

# Get description (max 50 chars)
while true; do
    read -p "Enter description (max 50 chars): " description
    if [[ -z $description ]]; then
        echo "Error: Description cannot be empty."
    elif [[ ${#description} -gt 50 ]]; then
        echo "Error: Description exceeds 50 characters. Please try again."
    else
        break
    fi
done

# Get detailed descriptions
detailed_descriptions=()
while true; do
    read -p "Enter detailed description (optional, press enter to finish): " detail
    if [[ -z $detail ]]; then
        break
    else
        detailed_descriptions+=("$detail")
    fi
done

# Construct commit message
commit_message="$commit_type$scope_part: $description"

if [ ${#detailed_descriptions[@]} -gt 0 ]; then
    commit_message+="\n\n"
    for detail in "${detailed_descriptions[@]}"; do
        commit_message+="- $detail\n"
    done
fi

# Display the commit message
echo -e "\nCommit Message:"
echo -e "\n"
echo -e "$commit_message"

# Confirm before committing
read -p "Do you want to commit these changes? (y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    # Stage all changes
    git add .

    # Create git commit
    git commit -m "$(echo -e "$commit_message")"

    echo "Changes staged and committed successfully."
else
    echo "Commit cancelled."
fi
