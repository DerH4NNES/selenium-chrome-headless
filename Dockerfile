FROM debian:stable-slim
MAINTAINER Suriya Soutmun <suriya@odd.works>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qqy \
  && apt-get -qqy install \
       libgconf2-4 wget curl \
       ca-certificates apt-transport-https \
       ttf-wqy-zenhei \
       fonts-thai-tlwg-ttf \
       sudo \
  && apt-get -qqy install gnupg --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#===========
# OpenJDK 8
#===========
RUN mkdir -p /usr/share/man/man1 \
  && echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list.d/jessie-backports.list \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    -t jessie-backports openjdk-8-jre-headless \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==============
# ChromeDriver
#==============
ARG CHROME_DRIVER_VERSION=2.41
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

COPY chrome_launcher.sh /opt/google/chrome/google-chrome

# Fixes https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

ENTRYPOINT ["java","-jar","/opt/selenium/chromedriver -port=4444 --url-base=/wd/hub"]

EXPOSE 4444
