#!/usr/bin/env bash

# using the deploy script from Vue CLI

# abort on errors
set -e

# build
make clean
make
#make search




# navigate into the build output directory
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

parent_dir="$(dirname "$script_dir")"

cp -rf ./html/. $parent_dir

cd $parent_dir

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME



cd -
