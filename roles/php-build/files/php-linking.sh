#!/usr/bin/env bash

definition=`basename $PWD`

if [[ $definition = $'5.3.'* ]]; then
  sed -i "/^BUILD_/ s/\$(CC)/\$(CXX)/g" Makefile
  sed -i "/EXTRA_LIBS = /s|$| -lstdc++|" Makefile
fi
