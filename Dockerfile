FROM ruby:2.0.0-p648
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA8E81B4331F7F50 2B90D010 \
  C857C906 518E17E1 473041FA B98321F9 \
  46925553 65FFB764 
RUN apt-key list | grep expired
RUN apt-key update debian-archive-keyring
RUN apt-get install -y file \
  git debian-archive-keyring
RUN apt-get update
RUN apt-get install -y --force-yes  libffi-dev \
  sqlite3 \
  libc-dev \ 
  libxml2-dev \
  nodejs \
  libxslt-dev \
  make \
  openssl \
  tzdata \
  libwebp-dev libjpeg-dev libpng-dev wget freetype2-demos libfreetype6-dev libfreetype6
# RUN  apt-get install -y --force-yes libmagickwand-dev imagemagick graphicsmagick 
RUN apt-get update 
RUN apt-get upgrade -y --force-yes
WORKDIR /home
RUN git clone https://github.com/ImageMagick/ImageMagick6.git ImageMagick
WORKDIR /home/ImageMagick
RUN git checkout 6.9.12-72
RUN ./configure
RUN make
RUN make install
RUN ldconfig /usr/local/lib
RUN export MAGICK_HOME="$HOME/ImageMagick"
RUN export PATH="$MAGICK_HOME/bin:$PATH"
RUN LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$MAGICK_HOME/lib"; export LD_LIBRARY_PATH
RUN ldconfig /usr/local/lib
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN export PATH="/usr/include:$PATH"
RUN export SECRET_TOKEN=1905a204e4da4b7b249ad99e4481c7d570c9d25f88b8e8043eb6661b2d5a4105
RUN export RAILS_ENV=development
RUN bundle check || bundle install

COPY . ./ 

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
