#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
v8=$DIR/v8

if [ -d "$v8" ]; then
  (cd $v8                      \
    && git reset master --hard \
    && git clean -f -d         \
    && git checkout master     \
  )
else
  git clone v8 $v8
fi

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

  # only update versions we haven't documented yet
  if [ ! -d "$DIR/v8-$v8_v" ]; then
    git reset master --hard
    git clean -f -d

    git checkout $v8_v                                                                                                    \
      && cat "$DIR/template.doxygen" | sed "s.__root__.$DIR.g; s/__version__/$v8_v/g; s/__node_version__/$node_v/g;" > "$DIR/v8.doxygen" \
      && doxygen "$DIR/v8.doxygen"
  fi
done

git reset master --hard
git clean -f -d
git checkout master

rm $DIR/v8.doxygen

echo 'links to code and docs to be included in readme'
echo ''

for (( i=0; i<${#versions[@]}; i=$i+2 ));
do
  v8_v="${versions[$i]}"
  node_v="${versions[$i + 1]}"

  echo '- [v8 __version__](https://thlorenz.github.io/v8-dox/build/v8-__version__/html/) | [code](https://github.com/v8/v8/tree/__version__) | [node __node_version__](https://github.com/joyent/node/tree/v__node_version__)' \
    | sed "s/__version__/$v8_v/g; s/__node_version__/$node_v/g;"
done
