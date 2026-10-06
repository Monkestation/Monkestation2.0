#!/bin/bash
set -euo pipefail

MAP=$1
MAP_CONFIG=${2:-""}

echo Testing $MAP

tools/deploy.sh ci_test
mkdir -p ci_test/config
mkdir -p ci_test/data

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt
if [ -n "$MAP_CONFIG" ]; then
    echo "$MAP_CONFIG" > ci_test/config/maps.txt
fi

#set the map
cp _maps/$MAP.json ci_test/data/next_map.json

DD_PARAMS="log-directory=ci"
if [ "${DMEOW:-1}" != "0" ]; then
	DD_PARAMS="$DD_PARAMS&dmeow"
fi

cd ci_test
DreamDaemon tgstation.dmb -close -trusted -verbose -params "$DD_PARAMS"

cd ..

mkdir -p data
if [ -d "ci_test/data/screenshots_new" ]; then
    mkdir -p data/screenshots_new
    cp -r ci_test/data/screenshots_new data/screenshots_new
fi
cp ci_test/data/unit_tests.json data/unit_tests.json

cat ci_test/data/logs/ci/clean_run.lk
