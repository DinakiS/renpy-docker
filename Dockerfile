FROM openjdk:8-slim

USER root

# RUN apk update && apk add --no-cache curl wget unzip tar python2 opencv

RUN apt-get update \
    && apt-get install -y python2 libgl1 wget curl unzip tar

# Android SDK
ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip" \
    ANDROID_VERSION=30 \
    ANDROID_BUILD_TOOLS_VERSION=30.0.2

# Download Android SDK
RUN mkdir /android-sdk \
    && cd /android-sdk  \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip

# Required Ren'Py version. = UPDATE IT HERE =
ENV RENPY_VERSION=7.5.3
ENV RENPY_PATH /opt/renpy
ENV SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy

# Downloading Ren'Py SDK and Rapt
RUN cd /usr/local \
    && wget https://www.renpy.org/dl/$RENPY_VERSION/renpy-$RENPY_VERSION-sdk.tar.bz2 \
    && wget https://www.renpy.org/dl/$RENPY_VERSION/renpy-$RENPY_VERSION-rapt.zip \
    && tar -xjf renpy-$RENPY_VERSION-sdk.tar.bz2 \
    && unzip renpy-$RENPY_VERSION-rapt.zip -d renpy-$RENPY_VERSION-sdk \
    && rm renpy-$RENPY_VERSION-sdk.tar.bz2 renpy-$RENPY_VERSION-rapt.zip \
    && mkdir -p /opt \
    && mv renpy-* /opt/renpy

# Move Android SDK to Ren'Py folder
ENV ANDROID_HOME="$RENPY_PATH/rapt/Sdk"
RUN mkdir -p "$ANDROID_HOME" \
    && mv /android-sdk/* "$ANDROID_HOME/" \
    && cd "$ANDROID_HOME" \
    && mv cmdline-tools latest \
    && mkdir cmdline-tools \
    && mv latest cmdline-tools/latest

RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --update
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# Creating local.properties with path to android.keystore
# and path to SDK
RUN mkdir $RENPY_PATH/rapt/project \
    && echo "key.alias=android\nkey.store.password=android\nkey.alias.password=android\nkey.store=$RENPY_PATH/android.keystore\nsdk.dir=$RENPY_PATH/rapt/Sdk" > $RENPY_PATH/rapt/project/local.properties

COPY ./renpy $RENPY_PATH

# Compiling "The Question" game to android.
# To download Gradle and test if everything works
RUN cd $RENPY_PATH \
  && sh renpy.sh launcher android_build ./the_question --dest /build-tmp \
  && rm -rf /build-tmp \
  && rm -rf $RENPY_PATH/rapt/bin \
  && rm -rf $RENPY_PATH/rapt/project/app/build/outputs/apk/release

RUN mkdir /build && mkdir /game

WORKDIR $RENPY_PATH
