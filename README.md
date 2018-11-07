template for a sane android kotlin setup that doesn't rely on any ide or
xml layouts.

build.sh is a mini build system that generates the android manifest,
sets up your android sdk paths, compiles, packages and signs the app

# requirement
* android sdk, build-tools, platform-tools and platform
* bash? not sure if everything in the script is pure sh compatible

# usage
connect your device via usb and simply run

```
./build.sh
```

which will compile, sign and deploy the app. the apk is in ```bin/```

the first time you run it will explain how to generate a keystore

# environment variables
* ANDROID_SDK_ROOT: path to the android sdk (default: opt/android-sdk)
* ANDROID_PLATFORM: platform version (default: android-28)
* ANDROID_BUILD_TOOLS: build tools version (default: 28.0.3)
* ANDROID_KEYSTORE: path to the keystore used for signing
  (default project_dir/key.keystore)"
