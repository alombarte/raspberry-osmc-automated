#!/bin/bash

#### I like prompt with colors:
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' ~/.bashrc

# Default editor
echo "export EDITOR=vi" >> ~/.bash_aliases

