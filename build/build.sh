#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
v8=$DIR/v8

if [ -d "$v8" ]; then
  (cd $v8                      \
    && git reset master --hard \
    && git clean -f -d         \
    && git checkout master     \
  )
fi

#git submodule update --init
#git submodule foreach git pull origin master

cd $v8

# get all git refs and sort by version number
versions=(`                                   \
  git for-each-ref                             \
    | awk '{ print $3 }'                       \
    | grep refs/tags                           \
    | sed 's.refs/tags/..'                     \
    | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n \
    | ../deps-of-node.js`)

for (( i=0; i<${#versions[@]}; i=$i+2 ));
do
  v8_v="${versions[$i]}"
  node_v="${versions[$i + 1]}"

  git reset master --hard
  git clean -f -d

  # only update versions we haven't documented yet
  if [ ! -d "$DIR/v8-$v8_v" ]; then
    git checkout $v8_v                                                                                                    \
      && cat "$DIR/template.doxygen" | sed "s.__root__.$DIR.g; s/__version__/$v8_v/g; s/__node_version__/$node_v/g;" > "$DIR/v8.doxygen" \
      && doxygen "$DIR/v8.doxygen"
  fi
done

git reset master --hard
git clean -f -d
git checkout master

rm $DIR/v8.doxygen