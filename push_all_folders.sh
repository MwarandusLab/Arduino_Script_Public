#!/bin/bash

# GitHub username and token
GITHUB_USERNAME="yourusername"
GITHUB_TOKEN="yourtoken"

# Base directory containing all the folders
BASE_DIR="/path/to/arduino"

# Loop through each folder in the base directory
for folder in "$BASE_DIR"/*; do
    if [ -d "$folder" ]; then
        # Get the folder name
        folder_name=$(basename "$folder")

        # Create the repository on GitHub
        response=$(curl -H "Authorization: token $GITHUB_TOKEN" \
            -d "{\"name\": \"arduino-$folder_name\", \"private\": false}" \
            https://api.github.com/user/repos)

        # Check if the repository was created successfully
        if echo "$response" | grep -q '"full_name"'; then
            echo "Repository arduino-$folder_name created successfully"
        else
            echo "Failed to create repository arduino-$folder_name"
            echo "$response"
            continue
        fi

        # Navigate to the folder
        cd "$folder"

        # Check if the folder is already a Git repository
        if [ -d ".git" ]; then
            # Fetch the latest changes to ensure the local repository is up to date
            git fetch origin

            # Check for changes
            if [ -n "$(git status --porcelain)" ]; then
                # There are changes, commit and push
                git add .
                git commit -m "Updated commit for $folder_name"
                git push origin master
                if [ $? -eq 0 ]; then
                    echo "Updated and pushed changes for $folder_name"
                else
                    echo "Failed to push changes for $folder_name"
                fi
            else
                # No changes
                echo "No changes for $folder_name, skipping"
            fi
        else
            # Initialize a new Git repository
            git init
            git add .
            git commit -m "Initial commit for $folder_name"

            # Add the remote repository
            git remote add origin "https://github.com/$GITHUB_USERNAME/arduino-$folder_name.git"

            # Push the commit to the remote repository
            git push -u origin master
            if [ $? -eq 0 ]; then
                echo "Initialized and pushed new repository for $folder_name"
            else
                echo "Failed to push new repository for $folder_name"
            fi
        fi

        # Navigate back to the base directory
        cd "$BASE_DIR"
    fi
done
