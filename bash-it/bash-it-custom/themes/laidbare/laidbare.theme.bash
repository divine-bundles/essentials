#!/usr/bin/env bash
#:title:        Divine asset sample: laidbare.theme.bash
#:author:       Grove Pyree
#:email:        grayarea@protonmail.ch
#:revdate:      2019.12.03
#:revremark:    A round of asset polishing for the house
#:created_at:   2019.12.03

## A minimalistic Bash theme that can be loaded via Bash-it framework.
#
## Storing prompt in Bash-it's preferred $PROMPT variable causes the prompt to 
#. be surrounded by \[ ... \] invisible characters. Although not a problem 
#. generally, this causes line wrapping problems in Hyper.js terminal:
#. https://github.com/zeit/hyper/issues/283
#
## Consequently, this file sets PS1 directly.
#

PS1='\n\[\033[1m\]$( [ $? -eq 0 ] && echo \[\033[32m\] || echo \[\033[31m\] )> \[\033[36m\]$( basename -- "$( pwd )" )\[\033[0m\] '