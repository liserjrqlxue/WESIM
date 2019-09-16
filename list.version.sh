#!/bin/bash
pwd=$(cd $(dirname $0) && pwd -P)
cd $pwd
currentGitHash=$(git rev-parse HEAD)
for i in * pipeline/*;do cd $i && (gitHash=$(git rev-parse HEAD);if [ "$gitHash" != "$currentGitHash" ];then echo -e "$(basename $i)\t$gitHash";fi);cd $pwd;done 2>>/dev/null |sort -V > version.list
