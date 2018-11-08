#!/bin/sh

# based on
# https://medium.com/@authmane512/how-to-build-an-apk-from-command-line-without-ide-7260e1e22676

dir="$(dirname "$0")"
wdir="$(realpath "$dir")"
exename="$(basename "$wdir")"

android_sdk="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
android_platform="${ANDROID_PLATFORM:-android-28}"
android_jar="$android_sdk/platforms/$android_platform/android.jar"
android_build_tools_version=${ANDROID_BUILD_TOOLS:-28.0.3}
android_build_tools="$android_sdk/build-tools/$android_build_tools_version"
android_keystore="${ANDROID_KEYSTORE:-$wdir/debug.keystore}"
apksigner_params=""

if [ ! -f "$android_keystore" ]; then
  echo "your keystore seems to be missing at $android_keystore"
  echo "create one by running"
  echo ""
  echo "  keytool -genkeypair -keystore "$android_keystore" \\"
  echo "    -deststoretype pkcs12 -keyalg RSA -keysize 2048"
  echo ""
  echo "or point ANDROID_KEYSTORE to the correct path"
  exit 1
fi

if [ "$(realpath "$android_keystore")" = "$wdir/debug.keystore" ]; then
  echo "W: using debug.keystore, don't actually use this apk in production"
  apksigner_params="--ks-key-alias=mykey --ks-pass=pass:androiddebug"
fi

if [ ! -d "$android_sdk" ]; then
  echo "can't find android sdk in $android_sdk"
  echo "please install it or point ANDROID_SDK_ROOT to the correct path"
  exit 1
fi

if [ ! -f "$android_jar" ]; then
  echo "can't find android platform at $android_jar"
  echo "please set ANDROID_PLATFORM to your version (eg: android-28)"
  echo "or install android-28 by running"
  echo ""
  echo "  sudo \"$android_sdk/tools/bin/sdkmanager\" \"platforms;android-28\""
  echo ""
  exit 1
fi

if [ ! -d "$android_sdk/platform-tools" ]; then
  echo "can't find android platform tools at $android_sdk/platform-tools"
  echo "install them by running"
  echo ""
  echo "  sudo \"$android_sdk/tools/bin/sdkmanager\" \"platform-tools\""
  echo ""
  exit 1
fi

if [ ! -d $android_build_tools ]; then
  echo "can't find android build tools at $android_build_tools"
  echo "install them by running"
  echo ""
  echo "  sudo \"$android_sdk/tools/bin/sdkmanager\" \"build-tools;28.0.3\""
  echo ""
  echo "or set ANDROID_BUILD_TOOLS to your version (eg: 28.0.3)"
  exit 1
fi

echo "sdk: $android_sdk"
echo "build tools: $android_build_tools"
PATH="$PATH:$android_sdk/tools/bin"
PATH="$PATH:$android_sdk/platform-tools"
PATH="$PATH:$android_build_tools"

build_inside_project() {
  namespace=$(
    find src/ -name *.kt | xargs cat |
      grep "package .*$" | cut -d' ' -f2- | tr -d \; | head -n1
  )
  echo "building $namespace"
  (
    rm -rf bin
    rm -rf obj
    mkdir bin
    mkdir obj
    mkdir -pv res/layout
    mkdir -v res/values
    mkdir -v res/drawable
  ) 2>/dev/null
  cat > AndroidManifest.xml << EOF
<?xml version='1.0'?>
<manifest xmlns:a='http://schemas.android.com/apk/res/android'
  package='${namespace}' a:versionCode='0' a:versionName='0'>
  <application a:label='$exename' a:allowBackup='false'>
    <activity a:name='${namespace}.MainActivity'>
      <intent-filter>
        <category a:name='android.intent.category.LAUNCHER'/>
        <action a:name='android.intent.action.MAIN'/>
      </intent-filter>
    </activity>
  </application>
</manifest>
EOF
  find src/ -name *.kt | xargs \
    kotlinc -d obj -classpath "src:$android_jar" -Werror || return $?
  dx --dex --output=bin/classes.dex obj || return $?
  cd bin
  aapt package -f -m -F "${exename}.unaligned.apk" \
    -M ../AndroidManifest.xml -S ../res -I "$android_jar"
  aapt add "${exename}.unaligned.apk" classes.dex || return $?
  apksigner sign --ks "$android_keystore" $apksigner_params \
    "${exename}.unaligned.apk" ||
    return $?
  zipalign -f 4 "${exename}.unaligned.apk" "${exename}.apk" || return $?
  cd ..
  adb shell pm clear $namespace || return $?
  adb uninstall $namespace || return $?
  adb install "bin/${exename}.apk" || return $?
  adb shell am start -n $namespace/.MainActivity || return $?
  adb logcat | grep "^./$namespace\..*$" || return $?
}

olddir="$(pwd)"
cd "$wdir" || exit $?
build_inside_project
res=$?
cd "$olddir"
exit $res
