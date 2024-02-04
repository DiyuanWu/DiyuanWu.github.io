#!/usr/bin/env sh

# using the deploy script from Vue CLI

# abort on errors
set -e

# build
make clean
make
#make search

# navigate into the build output directory
cp -rf ./html/. ~/website/DiyuanWu.github.io

cd ~/website/DiyuanWu.github.io

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME

git add -A
git commit -m 'deploy'

# if you are deploying to https://<USERNAME>.github.io
git push -u origin main


cd -
