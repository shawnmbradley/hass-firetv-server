FROM forumi0721/debian-armhf-base

ENV LANG C.UTF-8

ARG DOCKER_TAG
# Various labels used for image classification.
LABEL org.label-schema.build-date=%%BUILD_DATE%% \
      org.label-schema.name="firetv-server" \
      org.label-schema.description="Runs python-firetv-server as a hass.io addon." \
      org.label-schema.url="https://github.com/shawnmbradley/hassio-addons" \
      org.label-schema.vcs-url="https://github.com/shawnmbradley/hassio-addons/firetv-server" \
      org.label-schema.vcs-ref=%%VCS_REF%% \
      org.label-schema.vendor="Shawn M Bradley" \
      org.label-schema.version=$DOCKER_TAG \
      org.label-schema.schema-version="2.0"

RUN export DEBIAN_FRONTEND=noninteractive \
 \
 && apt-get -q -y update \
 && apt-get -q -y install curl \
                          git \
                          python \
                          python-pip \
                          python-m2crypto \
                          libusb-1.0-0 \
                          android-tools-adb \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 \
 && pip install --upgrade pip \
 && pip install pyyaml \
 && pip install flask \
 && pip install firetv[firetv-server] \
 && pip install git+git://github.com/google/python-adb.git@master

RUN echo "fix for newer firetv-server (use first adb to connect manually)" \
 \
 && pip install --upgrade git+git://github.com/google/python-adb.git@master \
 && adb start-server \
 \
 && sed -i '70i\            signer = sign_m2crypto.M2CryptoSigner(op.expanduser("~/.android/adbkey"))' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py \
 && sed -i '71i\            device = adb_commands.AdbCommands()' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py \
 && sed -i '72i\            self._adb = device.ConnectDevice(serial=self.host, rsa_keys=[signer])' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py \
 \
 && sed -i '73,74d' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py \
 \
 && sed -i '9ifrom adb import sign_m2crypto' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py \
 && sed -i '9iimport os.path as op' /usr/local/lib/python2.7/dist-packages/firetv/__init__.py

EXPOSE 5556

CMD firetv-server -d $FIRETV:5555
