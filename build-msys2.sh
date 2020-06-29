#! /bin/bash

echo "ls -l / [0]"
ls -l /
sudo pacman --noconfirm -Syu || exit 1
echo "ls -l / [1]"
ls -l /
sudo pacman --noconfirm -S wget || exit 1
(sudo mkdir -p /work && sudo chmod a+w /work) || exit 1
echo "ls -l / [2]"
ls -l /

cd /work || exit 1

(rm -f pacman-msys.conf && wget https://raw.githubusercontent.com/aferrero2707/docker-buildenv-mingw/master/pacman-msys.conf && sudo cp pacman-msys.conf /etc/pacman-msys.conf) || exit 1
(rm -f Toolchain-mingw-w64-x86_64.cmake && wget https://raw.githubusercontent.com/aferrero2707/docker-buildenv-mingw/master/Toolchain-mingw-w64-x86_64.cmake && sudo cp Toolchain-mingw-w64-x86_64.cmake /etc/Toolchain-mingw-w64-x86_64.cmake) || exit 1


sudo pacman --noconfirm --config /etc/pacman-msys.conf -Syu || exit 1

#for PKG in mingw-w64-x86_64-libjpeg-turbo-1.5.3-1-any.pkg.tar.xz mingw-w64-x86_64-lensfun-0.3.2-4-any.pkg.tar.xz mingw-w64-x86_64-gtk3-3.22.30-1-any.pkg.tar.xz mingw-w64-x86_64-gtkmm3-3.22.3-1-any.pkg.tar.xz; do
for PKG in mingw-w64-x86_64-libjpeg-turbo-1.5.3-1-any.pkg.tar.xz mingw-w64-x86_64-lensfun-0.3.2-4-any.pkg.tar.xz; do
	rm -f "$PKG"
	#wget http://repo.msys2.org/mingw/x86_64/"$PKG" || exit 1
	wget https://mirror.yandex.ru/mirrors/msys2/mingw/x86_64/"$PKG" || exit 1
	sudo pacman --noconfirm --config /etc/pacman-msys.conf -U "$PKG" || exit 1
done

sudo pacman --noconfirm --config /etc/pacman-msys.conf -S \
    mingw64/mingw-w64-x86_64-qt5 || exit 1
    
#if [ ! -e /msys2/mingw64/bin/rcc-real.exe ]; then
	sudo mv /msys2/mingw64/bin/rcc.exe /msys2/mingw64/bin/rcc-real.exe || exit 1
	sudo cp -a /sources/rcc.exe /msys2/mingw64/bin/rcc.exe || exit 1
#fi
    
#if [ ! -e /msys2/mingw64/bin/moc-real.exe ]; then
	sudo mv /msys2/mingw64/bin/moc.exe /msys2/mingw64/bin/moc-real.exe || exit 1
	sudo cp -a /sources/moc.exe /msys2/mingw64/bin/moc.exe || exit 1
#fi


for FPC in $(ls /msys2/mingw64/lib/pkgconfig/*.pc); do
sudo sed -i 's|=/mingw64|=/msys2/mingw64|g' "$FPC"
done

(cd / && sudo rm -f mingw64 && sudo ln -s /msys2/mingw64 mingw64) || exit 1
export PKG_CONFIG_PATH=/msys2/mingw64/lib/pkgconfig:$PKG_CONFIG_PATH

mkdir -p /work/w64-build || exit 1
cd /work/w64-build || exit 1

# build LibRaw 0.18
if [ ! -e LibRaw ]; then
	git clone https://github.com/LibRaw/LibRaw-cmake.git || exit 1
	git clone https://github.com/LibRaw/LibRaw.git || exit 1
    cd LibRaw || exit 1
    #git checkout 0.18.13 || exit 1
	cp -a ../LibRaw-cmake/* . || exit 1
    #autoreconf --install || exit 1
    #./configure --prefix=/usr/local || exit 1
    mkdir build || exit 1
    cd build || exit 1
    cmake \
 		-DCMAKE_TOOLCHAIN_FILE=/etc/Toolchain-mingw-w64-x86_64.cmake \
		-DCMAKE_C_FLAGS="'-mwin32 -m64'" \
		-DCMAKE_CXX_FLAGS="'-mwin32 -m64'" \
		-DWIN32=FALSE \
 		-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/msys2/mingw64 .. || exit 1
    make -j2 || exit 1
    sudo make install || exit 1
fi

# Get alglib
cd /work/w64-build || exit 1
rm -rf alglib* cpp
curl -L http://www.alglib.net/translator/re/alglib-3.14.0.cpp.gpl.tgz -O || exit 1
tar xf alglib-3.14.0.cpp.gpl.tgz || exit 1
export ALGLIB_ROOT=$(pwd)/cpp


cd /work/w64-build || exit 1
if [ ! -e exiv2-0.27.2-Source ]; then
	curl -LO https://www.exiv2.org/builds/exiv2-0.27.2-Source.tar.gz || exit 1
	tar xf exiv2-*.tar.gz || exit 1
	cd exiv2-0.27.2-Source || exit 1
	mkdir build || exit 1
	cd build || exit 1
	cmake \
 		-DCMAKE_TOOLCHAIN_FILE=/etc/Toolchain-mingw-w64-x86_64.cmake \
		-DCMAKE_C_FLAGS="'-mwin32 -m64 -fvisibility=default'" \
		-DCMAKE_CXX_FLAGS="'-mwin32 -m64 -fvisibility=default'" \
 		-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/msys2/mingw64 .. || exit 1
 	(make -j 3 && sudo make install) || exit 1
fi


sudo pacman --noconfirm -S qt5-base || exit 1

echo "Compiling HDRMerge"
ls /sources/hdrmerge
mkdir -p /work/w64-build/hdrmerge || exit 1
cd /work/w64-build/hdrmerge || exit 1
(cmake \
 -DCMAKE_TOOLCHAIN_FILE=/etc/Toolchain-mingw-w64-x86_64.cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_C_FLAGS="'-mwin32 -m64 -mthreads -msse2'" \
 -DCMAKE_C_FLAGS_RELEASE="'-DNDEBUG -O2'" \
 -DCMAKE_CXX_FLAGS="'-mwin32 -m64 -mthreads -msse2'" \
 -DCMAKE_CXX_FLAGS_RELEASE="'-DNDEBUG -O3'" \
 -DCMAKE_EXE_LINKER_FLAGS="'-m64 -mthreads -static-libgcc'" \
 -DCMAKE_EXE_LINKER_FLAGS_RELEASE="'-s -O3'" \
 -DWIN32=TRUE -DEXIV2_VERSION=0.27 \
 -DCMAKE_INSTALL_PREFIX=/msys2/mingw64 \
 -DAUTORCC_EXECUTABLE="/usr/bin/rcc --verbose" \
 -DALGLIB_ROOT=$ALGLIB_ROOT -DALGLIB_INCLUDES=$ALGLIB_ROOT/src -DALGLIB_LIBRARIES=$ALGLIB_ROOT/src \
 /sources/hdrmerge && make -j 3) || exit 1

touch /work/build.done
