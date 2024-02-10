Ren'Py Docker image with RAPT for making android builds in CI/CD.

[![Docker Pulls](https://img.shields.io/docker/pulls/dinaki/renpy)](https://hub.docker.com/r/dinaki/renpy)


## Usage
Android build
```
docker run -rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build \
  dinaki/renpy:latest \
  sh renpy.sh launcher android_build /game --dest /build
```

PC and Mac build
```
docker run -rm \
  -v "local/path/to/game:/game" \
  -v "local/path/to/build:/build \
  dinaki/renpy:latest \
  sh renpy.sh launcher distribute --dest /build --no-update --package pc --package mac /game
```
