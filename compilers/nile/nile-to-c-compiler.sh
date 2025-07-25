#!/bin/sh

DIR="$( cd "$( dirname "$0" )" && pwd )"
MARU_DIR="$DIR/../.."

set -x

make -C $MARU_DIR eval gceval peg-compile.l
$MARU_DIR/gceval -b $MARU_DIR/boot.l -L $MARU_DIR/ $DIR/nile-compiler.l \
  $DIR c $@
