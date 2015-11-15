FROM resin/rpi-raspbian:latest

# Set the timezone
RUN echo America/New_York | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# install the packages
RUN apt-get update && apt-get install -y \
  alsa-utils \
  chromium-bsu \
  chromium-inspector \
  curl \
  flite \
  libmono-sqlite4.0-cil \
  libmono-system-data-datasetextensions4.0-cil \
  libmono-system-data-linq4.0-cil \
  libmono-system-design4.0.cil \
  libmono-system-runtime-caching4.0-cil \
  libmono-system-web-extensions4.0-cil \
  libmono-system-web4.0.cil \
  libmono-system-xml-linq4.0-cil \
  libmono-system4.0-cil \
  libpopt0 \
  libttspico-data \
  mono-vbnc \
  sqlite3 \
  tar \
  wget

# download and unzip homeseer
WORKDIR /root
RUN wget http://homeseer.com/updates3/hs3_linux_3_0_0_208.tar.gz
RUN tar zxvf hs3_linux_3_0_0_208.tar.gz
RUN rm *.tar.gz

# get the missing pico2wave libraries and install them
RUN wget http://ftp.de.debian.org/debian/pool/non-free/s/svox/libttspico-utils_1.0+git20130326-3_armhf.deb
RUN wget http://ftp.de.debian.org/debian/pool/non-free/s/svox/libttspico0_1.0+git20130326-3_armhf.deb
RUN dpkg -i libttspico0_1.0+git20130326-3_armhf.deb
RUN dpkg -i libttspico-utils_1.0+git20130326-3_armhf.deb
RUN rm *.deb

# populate mono certificate store
# since this is the only file needed from mono-devel
# run it directly
RUN mkdir deb-mono-devel \
&& apt-get update && apt-get download mono-devel \
&& dpkg --extract mono-devel*.deb deb-mono-devel \
&& mono deb-mono-devel/usr/lib/mono/4.5/mozroots.exe --import --sync \
&& rm -rf deb-mono-devel \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Uncomment and use the following if you want to use a local plugin
# ADD updater_override.txt HomeSeer/updater_override.txt
# RUN mkdir -p HomeSeer/Updates3/Zips
# ADD ConcordV3_1_13_2.zip /root/HomeSeer/Updates3/Zips/ConcordV3_1_13_2.zip

# Expose the port and set the command
EXPOSE 80
CMD ["sh", "-c", "cd $HOME/HomeSeer && ./go"]
