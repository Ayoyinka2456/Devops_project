#!/bin/bash
git clone -b test --single-branch https://github.com/Ayoyinka2456/Devops_project.git temp_folder
cd temp_folder
git archive HEAD -- increment_counter.sh | tar -x
mv increment_counter.sh ..
cd ..
rm -rf temp_folder
source increment_counter.sh
