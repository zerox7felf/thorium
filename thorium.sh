#!/bin/bash

# Find path of this script
# Cheekily copied from https://stackoverflow.com/a/12197518
pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}";
while([ -h "${SCRIPT_PATH}" ]); do
    cd "`dirname "${SCRIPT_PATH}"`"
    SCRIPT_PATH="$(readlink "`basename "${SCRIPT_PATH}"`")";
done
cd "`dirname "${SCRIPT_PATH}"`" > /dev/null
SCRIPT_PATH="`pwd`";
popd > /dev/null
export LUA_PATH="${SCRIPT_PATH}/?.lua;;"

lua "${SCRIPT_PATH}/main.lua"
