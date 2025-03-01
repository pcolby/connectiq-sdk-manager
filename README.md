# Connect IQ SDK Manager AppImage

tl;dr Allows you to run [Garmin][]'s [Connect IQ][] [SDK Manager][] on modern Linux machines, such as [Ubuntu 24.04][]
or later.

## Why

The problem is that the *proprietary* [SDK Manager][] has a runtime link dependency to an old `webkit2gtk-4.0` library,
which Ubuntu stopped shipping sometime before 24.04, but [Garmin][] has still not updated the application to use a more
recent version.  Because [SDK Manager][] is closed source, we cannot simply modify it. However, we *can* package it into
an [AppImage][], along with ~all~ most of its dependencies.

## How to Use

First off, you do still need to make one small update to your OS as root :disappointed:

Create a symlink from the old (expected) `webkit2gtk-4.0` path to point to the newer `webkit2gtk-4.1` path:

```sh
sudo apt install libwebkit2gtk-4.1-0 # if not already installed.
sudo ln -sf webkit2gtk-4.1 /usr/lib/x86_64-linux-gnu/webkit2gtk-4.0
```

> [!IMPORTANT]
> Although the code in this repository is freely usable under the highly-permissive [MIT license][], the wrapped
> [SDK Manager][] is subject to [Garmin][]'s own [Connect IQ SDK license], so please be sure to accept that license
> *before* using this AppImage.

Once the symlink is in place, simply download the latest AppImage from the [releases][] page, unzip, and run :tada:

```sh
wget 'https://github.com/pcolby/connectiq-sdk-manager/releases/download/v0.1.0/connectiq-sdk-manager-1.0.13+50.AppImage.zip'
unzip connectiq-sdk-manager-1.0.13+50.AppImage.zip
./Connect_IQ_SDK_Manager-*-x86_64.AppImage
```

## How it Works

If you were to download the [SDK Manager][] from Garmin, and run it on a modern Ubuntu's, you will get an error like:

> `./bin/sdkmanager: error while loading shared libraries: libwebkit2gtk-4.0.so.37: cannot open shared object file: No
> such file or directory`

Of course this is because `sdkmanager` has a link dependency on the `libwebkit2gtk-4.0.so.37` library, which was
replaced with `libwebkit2gtk-4.1.so.0` sometime between Ubuntu 22.04 and 24.04. The ideal fix would be for [Garmin][]
to release an updates [SDK Manager][] (no doubt they will eventually), but in the meantime, we have this workaround.

So this [workflow][] uses a slightly older [Ubuntu 22.04][] image, since it has the required older library, and the
excellent [linuxdeploy][] utility to bundle the [SDK Manager][], along with all of its link and resource  dependencies
into a single [AppImage].

Unfortunately that is not quite enough, hence the symlink mentioned above. The reason is that first time you run the
the [SDK Manager][], it will present a _Connect IQ License Agreement_ dialog, which you must accept before proceding.
This dialog uses a webkit instance to render, and so the `libwebkit2gtk-4.0.so.37` library tries to invoke
`/usr/lib/x86_64-linux-gnu/webkit2gtk-4.0/WebKitNetworkProcess`, which of course, does not exist, and cannot be simply
included in the AppImage. However, if you have the newer `libwebkit2gtk-4.1-0` installed, then you can simply symlink
the old path to the new one, and then invocation works just fine.

Interestingly, once you've accepted the terms, and logged in to [Garmin][] (via the [SDK Manager]), the symlink does
not appear to needed any more, and you can probaby safely remove it again. Though there's no real harm leaving it there
either.

[AppImage]: https://appimage.org/
[Connect IQ]: https://developer.garmin.com/connect-iq/overview/
[Connect IQ SDK license]: https://developer.garmin.com/connect-iq/sdk/
[Garmin]: https://www.garmin.com/
[linuxdeploy]: https://github.com/linuxdeploy/linuxdeploy
[MIT license]: LICENSE.md
[releases]: https://github.com/pcolby/connectiq-sdk-manager/releases
[SDK Manager]: https://developer.garmin.com/connect-iq/sdk/
[Ubuntu 22.04]: https://ubuntu.com/blog/tag/22-04-lts
[Ubuntu 24.04]: https://ubuntu.com/blog/tag/ubuntu-24-04-lts
[workflow]: .github/workflows/package.yaml
