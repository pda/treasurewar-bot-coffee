#!/bin/sh

IN=coffee/
OUT=js/

set -e -x

coffee --watch --output $OUT $IN
