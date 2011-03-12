#!/bin/bash

variant=$1
if [ x"$variant" == x"release" ] ; then
    echo "Building release binaries"
    output=`pwd`/out.release
    cfg_switches=--disable-debug
    webkit_output="Release"
    tinyxml_switches="DEBUG=YES"
    CPPFLAGS="-O2"
    LDFLAGS="-g -lX11 -lcairo"
elif [ x"$variant" == x"debug" ] ; then
    echo "Building debug binaries"
    output=`pwd`/out.debug
    tinyxml_switches=
    webkit_output="Debug"
    cfg_switches=--enable-debug
    CPPFLAGS="-O0 -g"
    LDFLAGS="-g"
else
    echo "Usage: $0 [release|debug]\n";
    exit 1
fi

LBITS=`getconf LONG_BIT`
if [ x$LBITS == x"64" ] ; then
    echo "Building 64-bit binaries"
    WXWIDGETS_EXTRA_CFLAGS=
elif [ x$LBITS == x"32" ] ; then
    echo "Building 32-bit binaries"
    WXWIDGETS_EXTRA_CFLAGS="-D_FILE_OFFSET_BITS=32"
else
    echo "Cannot determine target architecture"
    exit 1
fi

echo "Going to place output in $output"

if [[ ! -e $output ]]; then
    mkdir -p $output
fi

# wxwebkit
pushd webkit
WebKitTools/Scripts/set-webkit-configuration --${variant}
PATH="$output/bin:${PATH}" ./WebKitTools/Scripts/build-webkit --wx --wx-args=wxgc,ENABLE_OFFLINE_WEB_APPLICATIONS=0,ENABLE_DOM_STORAGE=1,ENABLE_DATABASE=0,ENABLE_ICONDATABASE=0,ENABLE_XPATH=1,ENABLE_XSLT=1,ENABLE_VIDEO=0,ENABLE_SVG=0,ENABLE_COVERAGE=0,ENABLE_WML=0,ENABLE_WORKERS=0 &&
    mv ./WebKitBuild/${webkit_output}*/*.a $output/lib &&
    cp ./WebKit/wx/*.h $output/include/wx-2.8/wx &&
    strip -g $output/lib/libwxwebkit.a ||
        ( echo "Cannot compile WebKit" ; exit 1 )
popd
read -p "Press any key to continue..."

