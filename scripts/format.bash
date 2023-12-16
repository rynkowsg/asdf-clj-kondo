#!/usr/bin/env bash

shfmt --language-dialect bash \
  --indent 2 \
  --case-indent \
  --binary-next-line \
  --write \
  ./**/*

# Options:
# https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd
