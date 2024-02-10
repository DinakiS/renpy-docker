Ren'Py Docker image for building android games in CI/CD.

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
