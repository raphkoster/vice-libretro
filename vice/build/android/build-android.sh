#!/bin/sh

VICEVERSION=2.4.2

# see if we are in the top of the tree
if [ ! -f configure.in ]; then
  cd ../..
  if [ ! -f configure.in ]; then
    echo "please run this script from the base of the VICE directory"
    exit 1
  fi
fi

curdir=`pwd`

# set all cpu builds to no
armbuild=no
arm7abuild=no
mipsbuild=no
x86build=no

showusage=no

buildrelease=no
builddevrelease=no
builddebug=no

buildemulators=0

# check options
for i in $*
do
  if test x"$i" = "xarmeabi"; then
    armbuild=yes
  fi
  if test x"$i" = "xarmeabi-v7a"; then
    arm7abuild=yes
  fi
  if test x"$i" = "xmips"; then
    mipsbuild=yes
  fi
  if test x"$i" = "xx86"; then
    x86build=yes
  fi
  if test x"$i" = "xall-cpu"; then
    armbuild=yes
    arm7abuild=yes
    mipsbuild=yes
    x86build=yes
  fi
  if test x"$i" = "xhelp"; then
    showusage=yes
  fi
  if test x"$i" = "xrelease"; then
    buildrelease=yes
  fi
  if test x"$i" = "xx64"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="x64"
    emulib="libx64.so"
    emuname="AnVICE_x64"
  fi
  if test x"$i" = "xx64sc"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="x64sc"
    emulib="libx64sc.so"
    emuname="AnVICE_x64sc"
  fi
  if test x"$i" = "xx64dtv"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="x64dtv"
    emulib="libx64dtv.so"
    emuname="AnVICE_x64dtv"
  fi
  if test x"$i" = "xxscpu64"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xscpu64"
    emulib="libxscpu64.so"
    emuname="AnVICE_xscpu64"
  fi
  if test x"$i" = "xx128"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="x128"
    emulib="libx128.so"
    emuname="AnVICE_x128"
  fi
  if test x"$i" = "xxcbm2"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xcbm2"
    emulib="libxcbm2.so"
    emuname="AnVICE_xcbm2"
  fi
  if test x"$i" = "xxcbm5x0"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xcbm5x0"
    emulib="libxcbm5x0.so"
    emuname="AnVICE_xcbm5x0"
  fi
  if test x"$i" = "xxpet"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xpet"
    emulib="libxpet.so"
    emuname="AnVICE_xpet"
  fi
  if test x"$i" = "xxplus4"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xplus4"
    emulib="libxplus4.so"
    emuname="AnVICE_xplus4"
  fi
  if test x"$i" = "xxvic"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="xvic"
    emulib="libxvic.so"
    emuname="AnVICE_xvic"
  fi
  if test x"$i" = "xvsid"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="vsid"
    emulib="libvsid.so"
    emuname="AnVICE_vsid"
  fi
  if test x"$i" = "xall-emu"; then
    buildemulators=`expr $buildemulators + 1`
    emulator="all emulators"
    emulib="libvice.so"
    emuname="AnVICE"
  fi
done

if test x"$showusage" = "xyes"; then
  echo "Usage: $0 [release] [<cpu types>] [emulator] [help]"
  echo "release indicates that the binary needs to be build as a official release as opposed to a developent release."
  echo "cpu-types: armeabi, armeabi-v7a, mips, x86 (or all-cpu for all)."
  echo "if no cpu-type is given armeabi will be built by default."
  echo "emulators: x64, x64sc, x64dtv, xscpu64, x128, xcbm2, xcbm5x0, xpet, xplus4, xvic, vsid (or all-emu for all emulators)."
  exit 1
fi

if test x"$buildemulators" = "x0"; then
  emulator="x64"
  emulib="libx64.so"
  emuname="AnVICE_x64"
else
  if test x"$buildemulators" != "x1"; then
    echo "Only one emulator option can be given"
    exit 1
  fi
fi

CPUS=""

if test x"$armbuild" = "xyes"; then
  CPUS="armeabi"
fi

if test x"$arm7abuild" = "xyes"; then
  if test x"$CPUS" = "x"; then
    CPUS="armeabi-v7a"
  else
    CPUS="$CPUS armeabi-v7a"
  fi
fi

if test x"$mipsbuild" = "xyes"; then
  if test x"$CPUS" = "x"; then
    CPUS="mips"
  else
    CPUS="$CPUS mips"
  fi
fi

if test x"$x86build" = "xyes"; then
  if test x"$CPUS" = "x"; then
    CPUS="x86"
  else
    CPUS="$CPUS x86"
  fi
fi

if test x"$CPUS" = "x"; then
  CPUS="armeabi"
fi

if test x"$CPUS" = "xarmeabi armeabi-v7a mips x86"; then
  CPULABEL="all"
else
  CPULABEL=$CPUS
fi

if test x"$buildrelease" = "xyes"; then
  if [ ! -f vice-release.keystore ]; then
    echo "vice-release.keystore not found, will fallback on a debug build"
    buildrelease=no
    builddebug=yes
  fi
else
  if [ ! -f vice-dev.keystore ]; then
    echo "vice-dev.keystore not found, will use a debug key instead"
    builddebug=yes
  else
    builddebug=no
    builddevrelease=yes
  fi
fi

cd src

echo generating src/translate_table.h
. ./gentranslatetable.sh <translate.txt >translate_table.h

echo generating src/translate.h
. ./gentranslate_h.sh <translate.txt >translate.h

echo generating src/infocontrib.h
. ./geninfocontrib_h.sh <../doc/vice.texi | sed -f infocontrib.sed >infocontrib.h

cd arch/android/AnVICE/jni

echo generating Application.mk
cp Application.mk.proto Application.mk
echo >>Application.mk "APP_ABI := $CPUS"

echo clearing out all Android.mk files
for i in `find . -name "Android.mk"`
do
  rm -f $i
done

echo generating Android.mk files for $emulator

if test x"$emulator" = "xx64"; then
  cp Android.mk.proto Android.mk
  cp locnet/Android-x64.mk.proto locnet/Android.mk
  cp locnet_al/Android.mk.proto locnet_al/Android.mk
  cp vice_c64cart/Android.mk.proto vice_c64cart/Android.mk
  cp vice_c64exp/Android.mk.proto vice_c64exp/Android.mk
  cp vice_common/Android.mk.proto vice_common/Android.mk
  cp vice_commonall/Android.mk.proto vice_commonall/Android.mk
  cp vice_commoncart/Android.mk.proto vice_commoncart/Android.mk
  cp vice_iec/Android.mk.proto vice_iec/Android.mk
  cp vice_ieeepar/Android.mk.proto vice_ieeepar/Android.mk
  cp vice_tape/Android.mk.proto vice_tape/Android.mk
  cp vice_vicii/Android.mk.proto vice_vicii/Android.mk
  cp vice_x64/Android.mk.proto vice_x64/Android.mk
fi

if test x"$emulator" = "xx64sc"; then
  cp Android.mk.proto Android.mk
  cp locnet/Android-x64sc.mk.proto locnet/Android.mk
  cp locnet_al/Android.mk.proto locnet_al/Android.mk
  cp vice_c64cart/Android.mk.proto vice_c64cart/Android.mk
  cp vice_c64exp/Android.mk.proto vice_c64exp/Android.mk
  cp vice_common/Android.mk.proto vice_common/Android.mk
  cp vice_commonall/Android.mk.proto vice_commonall/Android.mk
  cp vice_commoncart/Android.mk.proto vice_commoncart/Android.mk
  cp vice_iec/Android.mk.proto vice_iec/Android.mk
  cp vice_ieeepar/Android.mk.proto vice_ieeepar/Android.mk
  cp vice_tape/Android.mk.proto vice_tape/Android.mk
  cp vice_viciisc/Android.mk.proto vice_viciisc/Android.mk
  cp vice_x64sc/Android.mk.proto vice_x64sc/Android.mk
fi

if test x"$emulator" = "xx64dtv"; then
  cp Android.mk.proto Android.mk
  cp locnet/Android-x64dtv.mk.proto locnet/Android.mk
  cp locnet_al/Android.mk.proto locnet_al/Android.mk
  cp vice_c64exp/Android.mk.proto vice_c64exp/Android.mk
  cp vice_common/Android.mk.proto vice_common/Android.mk
  cp vice_commonall/Android.mk.proto vice_commonall/Android.mk
  cp vice_iec/Android.mk.proto vice_iec/Android.mk
  cp vice_ieeepar/Android.mk.proto vice_ieeepar/Android.mk
  cp vice_tape/Android.mk.proto vice_tape/Android.mk
  cp vice_vicii/Android.mk.proto vice_vicii/Android.mk
  cp vice_x64dtv/Android.mk.proto vice_x64dtv/Android.mk
fi

echo building $emulib
cd ..

if test x"$emulator" = "xx64"; then
   sed -e 's/@VICE@/AnVICE_x64/g' -e 's/@VICE_ROM@/C64 ROM \(KERNAL\)/g' <res_values_string.xml.proto >res/values/strings.xml
   cp assets/sdl-vicerc-x64 assets/sdl-vicerc
fi

if test x"$emulator" = "xx64sc"; then
   sed -e 's/@VICE@/AnVICE_x64sc/g' -e 's/@VICE_ROM@/C64SC ROM \(KERNAL\)/g' <res_values_string.xml.proto >res/values/strings.xml
   cp assets/sdl-vicerc-x64sc assets/sdl-vicerc
fi

if test x"$emulator" = "xx64dtv"; then
   sed -e 's/@VICE@/AnVICE_x64dtv/g' -e 's/@VICE_ROM@/C64DTV ROM \(KERNAL\)/g' <res_values_string.xml.proto >res/values/strings.xml
   cp assets/sdl-vicerc-x64dtv assets/sdl-vicerc
fi

ndk-build

echo generating needed java files

if test x"$emulator" = "xx64"; then
   sed -e s/@VICE@/x64/g -e s/@VICE_DATA_PATH@/c64/g -e s/@VICE_DATA_FILE@/kernal/g <src/com/locnet/vice/DosBoxLauncher.java.proto >src/com/locnet/vice/DosBoxLauncher.java
   sed s/@VICE_EMU@/setFileSummaryc64/g <src/com/locnet/vice/PreConfig.java.proto >src/com/locnet/vice/PreConfig.java
fi

if test x"$emulator" = "xx64sc"; then
   sed -e s/@VICE@/x64sc/g -e s/@VICE_DATA_PATH@/c64/g -e s/@VICE_DATA_FILE@/kernal/g <src/com/locnet/vice/DosBoxLauncher.java.proto >src/com/locnet/vice/DosBoxLauncher.java
   sed s/@VICE_EMU@/setFileSummaryc64/g <src/com/locnet/vice/PreConfig.java.proto >src/com/locnet/vice/PreConfig.java
fi

if test x"$emulator" = "xx64dtv"; then
   sed -e s/@VICE@/x64dtv/g -e s/@VICE_DATA_PATH@/c64dtv/g -e s/@VICE_DATA_FILE@/kernal/g <src/com/locnet/vice/DosBoxLauncher.java.proto >src/com/locnet/vice/DosBoxLauncher.java
   sed s/@VICE_EMU@/setFileSummaryc64dtv/g <src/com/locnet/vice/PreConfig.java.proto >src/com/locnet/vice/PreConfig.java
fi

echo generating apk

if test x"$buildrelease" = "xyes"; then
  cp $curdir/vice-release.keystore ./
  echo >ant.properties "key.store=vice-release.keystore"
  echo >>ant.properties "key.alias=vice_release"
fi

if test x"$builddevrelease" = "xyes"; then
  cp $curdir/vice-dev.keystore ./
  echo >ant.properties "key.store=vice-dev.keystore"
  echo >>ant.properties "key.alias=vice_dev"
fi

if test x"$builddebug" = "xyes"; then
  rm -f ant.properties
  ant debug
  cd ../../../..
  mv src/arch/android/AnVICE/bin/PreConfig-debug.apk ./$emuname-\($CPULABEL\)-$VICEVERSION.apk
else
  ant release
  rm -f vice-*.keystore
  rm -f ant.properties
  cd ../../../..
  mv src/arch/android/AnVICE/bin/PreConfig-release.apk ./$emuname-\($CPULABEL\)-$VICEVERSION.apk
fi

if [ ! -f $emuname-\($CPULABEL\)-$VICEVERSION.apk ]; then
  echo build not completed, check for errors in the output
else
  echo Android port binary generated as $emuname-\($CPULABEL\)-$VICEVERSION.apk
fi
