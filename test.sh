#!/usr/bin/env bash

if [ ! -z "$(git status --porcelain)" ]; then
    echo "⚠️ This script will mess up your working tree, make sure to clean/commit changes first"
    exit 1
fi

if [ ! -z "$(git stash list)" ]; then
    echo "⚠️ This script might mess your stashes, make sure to clean/apply,commit first"
    exit 1
fi

echo "Hello World" > test1.txt
echo "Bye World" > test2.txt
echo "1 + 1 = 2" > maths.txt

git add --all

git stash push --include-untracked --message "Add test1.txt" -- test1.txt
git stash push --include-untracked --message "Add test2.txt" -- test2.txt
git stash push --include-untracked --message "Some maths" -- maths.txt

bash git-zash.sh --backup

git stash clear
