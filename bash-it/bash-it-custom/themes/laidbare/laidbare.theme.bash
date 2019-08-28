#!/usr/bin/env bash

## Storing prompt in Bash-it's preferred $PROMPT variable causes the prompt to 
#. be surrounded by \[ ... \] invisible characters. Although not a problem 
#. generally, this causes line wrapping problems in Hyper.js terminal:
#. https://github.com/zeit/hyper/issues/283
#
## Consequently, this files sets $PS1 directly.

PS1='\n\[\033[1m\]$( [ $? -eq 0 ] && echo \[\033[32m\] || echo \[\033[31m\] )> \[\033[36m\]$( basename -- "$( pwd )" )\[\033[0m\] '