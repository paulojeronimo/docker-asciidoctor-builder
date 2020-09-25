#!/usr/bin/env bash
set -eou pipefail

cd "`dirname "$0"`/.."
echo "Base dir is \"$PWD\""
source ./build.conf 2> /dev/null || echo "$PWD/build.conf not found"
build_dir=${build_dir:-build}

docker-asciidoctor() {
  docker run -e TZ=America/Sao_Paulo -it --rm \
    -v "$PWD":/documents \
    asciidoctor/docker-asciidoctor "$@"
}

html() {
  local tag
  while [ "${1:-}" ]; do
    case "$1" in
      -t|--tag)
        shift
        [ "${1:-}" ] && tag=$1 || {
          echo "Please, specify the tag!"
          exit 1
        }
        git stash &> /dev/null
        git tag -l | grep -q "^$tag$" || {
          echo "Git tag is invalid!"
          git stash pop &> /dev/null
          exit 1
        }
        git checkout $tag &> /dev/null
        build_dir=$build_dir/$tag
    esac
    shift || break
  done
  docker-asciidoctor asciidoctor -D $build_dir README.adoc -o index.html
  ! [ -d outputs ] || rsync -a outputs $build_dir/
  if [ "${tag:-}" ]; then
    git checkout master &> /dev/null
    git stash pop &> /dev/null || :
  fi
}

gh-pages() {
  [ -d $build_dir ] || { echo "\"$build_dir\" directory does not exists!"; return 1; }
  echo "Publish the contents in \"$build_dir\" to GitHub Pages ..."
  local remote_repo=${remote_repo:-`git config --get remote.origin.url`}
  local msg="Published at `date`"
  cd $build_dir
  git init
  git add -A
  git commit -m "$msg"
  git push --force $remote_repo master:gh-pages
}

usage() {
  echo "Usage: $0 <[html] [-<t|-tag> <tag>]|gh-pages>"
  exit 0
}

if [ "${1:-}" ]; then
  [[ $1 =~ ^- ]] && { task=html; set -- html "$@"; } || task=$1
else
  task=html
fi
shift || :
type $task &> /dev/null || usage
$task ${@:-}
