#!/bin/sh

rm -fr aclocal.m4 autom4te.cache/
autoreconf -iv
./configure
