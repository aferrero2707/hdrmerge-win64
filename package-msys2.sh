#!/bin/bash

set -xv

# transfer.sh
transfer() 
{ 
	if [ $# -eq 0 ]; then 
		echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; 		
		return 1; 
	fi
	tmpfile=$( mktemp -t transferXXX ); 
	if tty -s; then 
		basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); 
		curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; 
	else 
		curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; 
	fi; 
	cat $tmpfile; 
	rm -f $tmpfile; 
}

/usr/bin/x86_64-w64-mingw32-gcc -v

# unzip to here
export installdir=/mingw64

if [ ! -e /work/build.done ]; then
	$TRAVIS_BUILD_DIR/build-msys2.sh || exit 1
fi


export VERSION="${BUILD_BRANCH}_${GIT_DESCRIBE}_$(date +%Y%m%d)"
REPACKAGEDIR=/work/w64-build/hdrmerge/hdrmerge_${VERSION}

rm -rf ${REPACKAGEDIR}
mkdir -p ${REPACKAGEDIR} || exit 1

cp -a /work/w64-build/hdrmerge/hdrmerge.exe ${REPACKAGEDIR} || exit 1
cp -a /work/w64-build/hdrmerge/hdrmerge-nogui.exe ${REPACKAGEDIR} || exit 1

cd /msys2/mingw64/bin || exit 1
cp -L libgomp-1.dll      libjasper-4.dll    libwinpthread-1.dll \
  libgraphite2.dll   libjpeg-8.dll \
libbz2-1.dll       libdouble-conversion.dll libharfbuzz-0.dll  liblcms2-2.dll     Qt5Core.dll \
libexiv2.dll        libiconv-2.dll     libpcre-1.dll      Qt5Gui.dll \
libexpat-1.dll      libicudt*.dll     libpcre2-16-0.dll  Qt5Widgets.dll \
libfreetype-6.dll   libicuin*.dll     libpng16-16.dll    zlib1.dll \
libgcc_s_seh-1.dll  libicuuc*.dll     libraw*.dll \
libglib-2.0-0.dll   libintl-8.dll      libstdc++-6.dll libzstd.dll \
${REPACKAGEDIR} || exit 1

cp -a /mingw64/share/qt5/plugins/platforms ${REPACKAGEDIR} || exit 1
cp -a /mingw64/share/qt5/plugins/imageformats ${REPACKAGEDIR} || exit 1


sudo pacman --noconfirm -S zip || exit 1
rm -f $TRAVIS_BUILD_DIR/hdrmerge_*.zip
cd /work/w64-build/hdrmerge/ || exit 1
echo "zip -q -r $TRAVIS_BUILD_DIR/hdrmerge_win64.zip hdrmerge_${VERSION}"
sudo zip -q -r $TRAVIS_BUILD_DIR/hdrmerge_${VERSION}_win64.zip hdrmerge_${VERSION} || exit 1

#transfer $TRAVIS_BUILD_DIR/hdrmerge_${VERSION}_win64.zip