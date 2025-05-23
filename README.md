# Connect IQ SDK Manager AppImage

tl;dr Allows you to run [Garmin][]'s [Connect IQ][] [SDK Manager][] on modern Linux machines, such as [Ubuntu 24.04][]
or later.

## Why

The problem is that the *proprietary* [SDK Manager][] has a runtime link dependency to an old `webkit2gtk-4.0` library,
which Ubuntu stopped shipping sometime before 24.04, but [Garmin][] has still not updated the application to use a more
recent version.  Because [SDK Manager][] is closed source, we cannot simply modify it. However, we *can* package it into
an [AppImage][], along with most of its dependencies.

## License

> [!IMPORTANT]
>
> The code in this repository is freely usable under the highly-permissive [MIT license][], however the packaged
> [SDK Manager][] is subject to [Garmin][]'s [Connect IQ SDK license], so please be sure to accept that license *before*
> using any of the AppImages from this project.

## How to Use

There is a convenience script ([`install.sh`][]) which can be used to download the latest [AppImage][]s and make them
*executable*, which you can run like:

```sh
curl -Ls https://raw.githubusercontent.com/pcolby/connectiq-sdk-manager/main/install.sh | bash -r
```

Here's an example output:

```text
Installing to: /home/paul/.Garmin/ConnectIQ/AppImages
Fetching details for release: latest
Found details for release: Continuous
Downloading Connect_IQ_+Monkey_Motion-4.2.4+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Monkey_Motion-4.2.4%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Monkey_Motion-4.2.4+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Monkey_Motion-6.4.2+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Monkey_Motion-6.4.2%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Monkey_Motion-6.4.2+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Monkey_Motion-7.4.3+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Monkey_Motion-7.4.3%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Monkey_Motion-7.4.3+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Monkey_Motion-8.1.1+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Monkey_Motion-8.1.1%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Monkey_Motion-8.1.1+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_SDK_Manager-1.0.14+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_SDK_Manager-1.0.14%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_SDK_Manager-1.0.14+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Simulator-4.2.4+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Simulator-4.2.4%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-4.2.4+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Simulator-6.4.2+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Simulator-6.4.2%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-6.4.2+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Simulator-7.4.3+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Simulator-7.4.3%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-7.4.3+65-x86_64.AppImage
######################################################################## 100.0%
Downloading Connect_IQ_Simulator-8.1.1+65-x86_64.AppImage
  src: https://github.com/pcolby/connectiq-sdk-manager/releases/download/continuous/Connect_IQ_Simulator-8.1.1%2B65-x86_64.AppImage
  dst: /home/paul/.Garmin/ConnectIQ/AppImages/Connect_IQ_Simulator-8.1.1+65-x86_64.AppImage
######################################################################## 100.0%
```

Otherwise you can just download the relevant [AppImage][] from the [releases][] page, and make it executable yourself.

## How it Works

If you were to download the [SDK Manager][] from Garmin, and run it on a modern Ubuntu's, you will get an error like:

> `./bin/sdkmanager: error while loading shared libraries: libwebkit2gtk-4.0.so.37: cannot open shared object file: No
> such file or directory`

Of course this is because `sdkmanager` has a link dependency on the `libwebkit2gtk-4.0.so.37` library, which was
replaced with `libwebkit2gtk-4.1.so.0` sometime between Ubuntu 22.04 and 24.04. The ideal fix would be for [Garmin][]
to release an updates [SDK Manager][] (no doubt they will eventually), but in the meantime, we have this workaround.

So this [workflow][] uses a slightly older [Ubuntu 22.04][] image, since it has the required older library, and the
excellent [linuxdeploy][] utility to bundle the [SDK Manager][], along with all of its link and resource  dependencies
into a single [AppImage][].

The resulting [AppImage][] still has a runtime dependency on some `webkit2gtk` executables (they are executed by
`libwebkit2gtk-4.0.so.37` to render some HTML views, such as the initial "Connect IQ License Agreement" dialog), however
a custom [linuxdeploy] plugin ([`linuxdeploy-plugin-webkitmod.sh`][]) is modifies the `libwebkit2gtk-4.0.so.37` library
to run those binaries from a `libwebkit2gtk-4.1` folder instead, so having `libwebkit2gtk-4.1-0` installed is
sufficient.

[AppImage]: https://appimage.org/
[Connect IQ]: https://developer.garmin.com/connect-iq/overview/
[Connect IQ SDK license]: https://developer.garmin.com/connect-iq/sdk/
[Garmin]: https://www.garmin.com/
[`install.sh`]: install.sh
[linuxdeploy]: https://github.com/linuxdeploy/linuxdeploy
[`linuxdeploy-plugin-webkitmod.sh`]: linuxdeploy-plugin-webkitmod.sh
[MIT license]: LICENSE.md
[releases]: https://github.com/pcolby/connectiq-sdk-manager/releases
[SDK Manager]: https://developer.garmin.com/connect-iq/sdk/
[Ubuntu 22.04]: https://ubuntu.com/blog/tag/22-04-lts
[Ubuntu 24.04]: https://ubuntu.com/blog/tag/ubuntu-24-04-lts
[workflow]: .github/workflows/package.yaml
