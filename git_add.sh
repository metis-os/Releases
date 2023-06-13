#!/bin/sh

# Set Git user information
git config --global user.email "hey@pwnwriter.xyz"
git config --global user.name "pwnwriter"

# Add all modified files to the staging area
git add .

# Commit changes with a descriptive message
commit_message="Automated Update at $(date +%Y-%m-%d)"
git commit -m "$commit_message"

# Push changes to the remote repository, forcing an update
git push --force

# Display a success message
echo "Added files to github successfully.............."

