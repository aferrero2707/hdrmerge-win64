#! /bin/bash

BUILD_BRANCH=master

if [ ! -e hdrmerge ]; then
  git clone https://github.com/jcelaya/hdrmerge.git --branch "${BUILD_BRANCH}" --single-branch
fi

docker run -it -v $(pwd):/sources -e "TRAVIS_BUILD_DIR=/sources" -e "BUILD_BRANCH=${BUILD_BRANCH}" -e "GIT_DESCRIBE=${GIT_DESCRIBE}" photoflow/docker-buildenv-mingw-manjaro-wine #bash /sources/package-msys2.sh
