#!/bin/sh

transcrypt -c aes-256-cbc -p "$(pass transcrypt/github.com/eqyiel/dotfiles)"
