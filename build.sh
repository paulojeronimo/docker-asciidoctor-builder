#!/usr/bin/env bash
set -eou pipefail
cd "`dirname "$0"`/.."
build_dir=build
html() {
  docker-asciidoctor -D $build_dir README.adoc -o index.html
}
gh-pages() {
  [ -d $build_dir ] || { echo "\"$build_dir\" directory does not exists!"; return 1; }
  echo "Publish the contents in \"$build_dir\" to GitHub Pages ..."
  local remote_repo=`git config --get remote.origin.url`
  local msg="Published at `date`"
  cd $build_dir
  git init
  git add -A
  git commit -m "$msg"
  git push --force $remote_repo master:gh-pages
}
"${@:-html}"
