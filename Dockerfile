FROM openjdk:8-slim as android_sdk
WORKDIR /android-sdk/cmdline-tools

ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip" \
    ANDROID_VERSION=33 \
    ANDROID_BUILD_TOOLS_VERSION=33.0.0

RUN apt-get update && apt-get install -y --no-install-recommends wget unzip && \
    wget -O sdk.zip $SDK_URL && \
    unzip sdk.zip && \
    mv cmdline-tools latest && \
    rm sdk.zip

RUN yes | /android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses
RUN /android-sdk/cmdline-tools/latest/bin/sdkmanager --update
RUN /android-sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-${ANDROID_VERSION}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

FROM busybox:1.36.1 as renpy
WORKDIR /renpy-sdk
ENV RENPY_VERSION=7.6.3

RUN wget -O renpy.tar.bz2 https://www.renpy.org/dl/$RENPY_VERSION/renpy-$RENPY_VERSION-sdk.tar.bz2 && \
    wget -O rapt.zip https://www.renpy.org/dl/$RENPY_VERSION/renpy-$RENPY_VERSION-rapt.zip
RUN tar -xjf renpy.tar.bz2 && \
    unzip rapt.zip -d renpy-$RENPY_VERSION-sdk && \
    rm renpy.tar.bz2 rapt.zip && \
    mkdir /renpy && \
    mv renpy-*/* /renpy && \
    rm -rf /renpy/doc /renpy/tutorial

FROM openjdk:8-slim as build
WORKDIR /renpy
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python2 libgl1

COPY --from=renpy /renpy /renpy
COPY ./renpy .
COPY --from=android_sdk /android-sdk /renpy/rapt/Sdk/

# Creating local.properties with path to android.keystore
# and path to SDK
RUN mkdir /renpy/rapt/project \
    && echo "key.alias=android\nkey.store.password=android\nkey.alias.password=android\nkey.store=/renpy/the_question/android.keystore\nsdk.dir=/renpy/rapt/Sdk" > /renpy/rapt/project/local.properties

# Compiling "The Question" game to android.
# To download Gradle and test if everything works
RUN sh renpy.sh launcher android_build ./the_question --dest /build-tmp || true && \
  rm -rf /build-tmp || true && \
  rm -rf /renpy/rapt/bin && \
  rm -rf /renpy/rapt/project/app/build && \
  rm -rf /renpy/rapt/project/app/src && \
  rm -rf /renpy/tmp

# === Final ===
FROM openjdk:8-slim

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends python2 libgl1

ENV RENPY_VERSION=7.6.3 \
    RENPY_PATH=/opt/renpy \
    SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
    ANDROID_HOME="$RENPY_PATH/rapt/Sdk"

COPY --from=build /renpy $RENPY_PATH

RUN mkdir /build && mkdir /game

WORKDIR $RENPY_PATH
