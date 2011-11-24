#! /usr/bin/env sh

set -e -x

if [ ! -e ./configure ]; then
    ./autogen.sh
fi

./configure

make dist

VERSION="$(./configure --version | head -n1 | cut -d ' ' -f 3)"

ln -f betaradio-${VERSION}.tar.bz2 betaradio_${VERSION}.orig.tar.bz2

tar xf betaradio_${VERSION}.orig.tar.bz2

cp -a ./debian betaradio-${VERSION}

cd betaradio-${VERSION}

debuild -S -sa

cd ..

pbuilder-dist unstable i386 build $(ls betaradio_${VERSION}-*.dsc)
