Ren'Py Docker image with Android and iOS support.

[![Docker Pulls](https://img.shields.io/docker/pulls/dinaki/renpy)](https://hub.docker.com/r/dinaki/renpy)

## Usage (starting from 8.2.1)
PC and Mac build
```
docker run --rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build" \
  dinaki/renpy:latest \
  sh renpy.sh launcher distribute --dest /build --no-update --package pc --package mac /game
```

Web build
```
docker run --rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build" \
  dinaki/renpy:web \
  sh renpy.sh launcher set_project /game && sh renpy.sh launcher web_build /game --dest /build/web
```

Android build
```
docker run --rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build" \
  dinaki/renpy:android \
  sh renpy.sh launcher android_build /game --dest /build
```

Create XCode project for iOS
```
docker run --rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build" \
  dinaki/renpy:ios \
  sh renpy.sh launcher ios_create /game /build/xcode
```

## Tags

- `RENPY_VERSION` and `latest` - build for Win/Linux/Mac
- `RENPY_VERSION-android` and `android` - build with RAPT for Android
- `RENPY_VERSION-ios` and `ios` - build with Ren'iOS for making XCode project
- `RENPY_VERSION-web` and `web` - build for web
