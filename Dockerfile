FROM debian:8.1

MAINTAINER taka2063

WORKDIR /root/

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get remove nginx nginx-full nginx-light nginx-common
RUN apt-get -y install wget net-tools build-essential tar
RUN apt-get -y install mysql-server mysql-client libmysqlclient-dev
RUN apt-get -y install libxml2-dev zlib1g-dev ImageMagick libmagickcore-dev libmagickwand-dev
RUN apt-get -y install ruby ruby-dev
RUN apt-get -y install libcurl3-dev
RUN apt-get -y install libssl-dev
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
COPY asset/passenger.list /etc/apt/sources.list.d/
RUN chown root.root /etc/apt/sources.list.d/*
RUN apt-get -y install apt-transport-https
RUN apt-get update
RUN apt-get -y install nginx-extras
RUN apt-get -y install passenger

# mysql
COPY asset/my.cnf /etc/mysql/my.cnf
COPY asset/redmine.sql /root/
RUN service mysql start && mysql -u root < /root/redmine.sql

# redmine
RUN wget http://www.redmine.org/releases/redmine-3.1.1.tar.gz
RUN tar xvf redmine-3.1.1.tar.gz
RUN mv redmine-3.1.1 /var/lib/redmine
COPY asset/database.yml /var/lib/redmine/config/
COPY asset/configuration.yml /var/lib/redmine/config/
RUN gem install bundler --no-rdoc --no-ri
RUN cd /var/lib/redmine && bundle install --without development test --path vendor/bundle
WORKDIR /var/lib/redmine
RUN bundle exec rake generate_secret_token
ENV RAILS_ENV production
RUN service mysql start && bundle exec rake db:migrate
RUN gem install passenger --no-rdoc --no-ri


RUN passenger-install-nginx-module --auto
COPY asset/nginx.conf /etc/nginx/
COPY asset/default /etc/nginx/sites-available/

RUN chown -R www-data:www-data /var/lib/redmine

COPY asset/init /root/
ENV DEBIAN_FRONTEND dialog

WORKDIR /root/

ENTRYPOINT /bin/bash /root/init

EXPOSE 80
