# Independent Google App Engine/Python development environment

FROM ubuntu:14.10
MAINTAINER Christopher Bartling <chris.bartling@gmail.com>


# Update

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y


# Supervisor
RUN apt-get install -y supervisor && \
  mkdir -p /var/log/supervisor && \
  supervisord --version
ADD configurations/supervisor/supervisor.conf /etc/supervisor/conf.d/supervisor.conf


# Version Control
RUN apt-get install -y git-core mercurial && git --version && hg --version 

# OpenSSH

ADD configurations/openssh/supervisor.conf /etc/supervisor/conf.d/openssh.conf
ADD configurations/openssh/ssh-setup.sh /ssh-setup.sh
ENV SSH_ROOT_PASSWORD root
RUN apt-get install -y openssh-server && \
  chmod +x /ssh-setup.sh && \
  mkdir -p /var/run/sshd && \
  chmod 755 /var/run/sshd && \
  (echo "root:root" | chpasswd) && \
  sed -i.bak -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' \
    /etc/ssh/sshd_config


# Zsh
RUN apt-get install -y zsh && \
  git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh && \
  chsh --shell $(which zsh) && \
  zsh --version
ADD configurations/oh-my-zsh/zshrc /root/.zshrc


# Python

RUN apt-get install -y python2.7 python-pil pylint && python --version 


# Node.js

# RUN apt-get install -y build-essential && \
#   curl -sL https://deb.nodesource.com/setup | sudo bash -
# RUN apt-get install -y nodejs && \
#   nodejs --version && \
#   npm install -g coffee-script bower grunt-cli gulp component yo eslint


# # io.js
#
# ENV IOJS_VERSION 1.4.2
# RUN apt-get install -y ca-certificates curl pkg-config python
# RUN gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D && \
#   curl -SLO "https://iojs.org/dist/v$IOJS_VERSION/iojs-v$IOJS_VERSION-linux-x64.tar.gz" && \
#   curl -SLO "https://iojs.org/dist/v$IOJS_VERSION/SHASUMS256.txt.asc" && \
#   gpg --verify SHASUMS256.txt.asc && \
#   grep " iojs-v$IOJS_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - && \
#   tar -xzf "iojs-v$IOJS_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 && \
#   rm "iojs-v$IOJS_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc
# RUN iojs --version


# # Ruby
#
# RUN apt-get install -y ruby ruby-dev ri && \
#   ruby --version && \
#   echo "Gem version:" && gem --version
# RUN gem install rake bundler sass && \
#   bundle --version && rake --version && sass --version && \
#   gem install compass && \
#   compass --version


# # Go
#
# RUN apt-get install -y golang && \
#   go version


# Google App Engine

# Download Google App Engine SDK
RUN wget -O /appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.18.zip

# Extract it
RUN apt-get install unzip -y
RUN unzip /appengine.zip -d /appengine

# Set up the Supervisor configuration
ADD configurations/app-engine/supervisor.conf /etc/supervisor/conf.d/appengine.conf

# Add the Google App Engine nag configuration
ADD configurations/app-engine/appcfg_nag /root/.appcfg_nag



# Clean up
RUN apt-get clean && apt-get autoremove


# Start
WORKDIR "/app"
VOLUME ["/app"]
EXPOSE 22 8000 8080
CMD ["supervisord", "-n"]