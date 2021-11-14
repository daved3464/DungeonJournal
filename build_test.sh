#!/bin/bash

## Build the project in a test directory

meson builddir -Dprofile=development --prefix ${HOME}/.local/devbuilds && \
ninja -C builddir && \
ninja -C builddir install
