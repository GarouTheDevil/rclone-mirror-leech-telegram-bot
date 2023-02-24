FROM sammax23/rcmltb

WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# FFmpeg
RUN aria2c -x 10 https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz && \
    tar xvf ffmpeg*.xz && \
    cd ffmpeg-*-static && \
    mv "${PWD}/ffmpeg" "${PWD}/ffprobe" /usr/local/bin/

RUN apt-get -y update && apt-get -qq install -y --no-install-recommends curl git gnupg2 unzip wget pv jq mediainfo

# add mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list' && apt update && apt install -y mkvtoolnix

# Install dovi_tool
RUN wget -P /tmp https://github.com/quietvoid/dovi_tool/releases/download/1.5.6/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN tar -C /usr/local/bin -xzf /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz
RUN rm /tmp/dovi_tool-1.5.6-x86_64-unknown-linux-musl.tar.gz

COPY . .

RUN rm -rf ffmpeg*.xz ffmpeg-*-static

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
RUN apt-get update && apt-get upgrade -y
RUN apt -qq update --fix-missing

CMD ["bash","start.sh"]
