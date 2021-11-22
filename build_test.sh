#!/bin/bash

## Build the project in a test directory

meson localbuild  -Dprofile=development --prefix ${HOME}/.local/devbuilds && \
ninja -C localbuild && \
ninja -C localbuild install
