#!/usr/bin/env bash

# Safety checks

if [ ! -z "$(git status --porcelain)" ]; then
    echo "⚠️ This script will mess up your working tree, make sure to clean/commit changes first"
    exit 1
fi

if [ ! -z "$(git stash list)" ]; then
    echo "⚠️ This script might mess your stashes, make sure to clean/apply,commit first"
    exit 1
fi

# Sample stashes creation

echo "Hello World" > test1.txt
git add test1.txt
git stash push --include-untracked --message "Add test1.txt"

echo "Bye World" > test2.txt
echo "Another file" > another
git add test2.txt another
git stash push --include-untracked --message "Two files"

echo "1 + 1 = 2" > maths.txt
git add maths.txt
git stash push --include-untracked --message "Some maths"

# Create backup and clear all stashes

bash git-zash.sh --backup

git stash clear
