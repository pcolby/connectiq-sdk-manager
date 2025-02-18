# Connect IQ SDK Manager AppImage

tl;dr Allows you to run [Garmin][]'s [Connect IQ][] [SDK Manager][] on modern Linxu machines, such as [Ubuntu 24.04][]
or later.

## Why

The problem is that the *proprietary* [SDK Manager][] has a runtime link dependency on an old `webkit2gtk-4.0` library,
which Ubuntu stopped shipping sometime before 24.04, but [Garmin][] has still not updated the application to use a more
recent version.  Because [SDK Manager][] is closed source, we cannot simply modify it. However, *can* package it into an
[AppImage][], along with ~all~ most of its dependencies.

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
# \todo curl ...
unzip connectiq-sdk-manager-*.AppImage.zip
./Connect_IQ_SDK_Manager-*-x86_64.AppImage
```

## How it Works

*\todo*


[AppImage]: https://appimage.org/
[Connect IQ]: https://developer.garmin.com/connect-iq/overview/
[Connect IQ SDK license]: https://developer.garmin.com/connect-iq/sdk/
[Garmin]: https://www.garmin.com/
[SDK Manager]: https://developer.garmin.com/connect-iq/sdk/
[releases]: https://github.com/pcolby/connectiq-sdk-manager/releases
[MIT license]: LICENSE.md
