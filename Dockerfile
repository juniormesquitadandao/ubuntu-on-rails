FROM ubuntu:20.04

MAINTAINER <JMD> contatc@juniormesquitadandao.com

SHELL ["/bin/bash", "-l", "-c"]

RUN apt update && \
  apt upgrade -y && \
  apt install -y sudo software-properties-common curl gnupg2

RUN adduser --disabled-password --gecos "" uor && \
  usermod -aG sudo uor && \
  passwd -d uor
USER uor

ONBUILD ARG RUBY_VERSION
ONBUILD ARG RAILS_VERSION
ONBUILD ARG BUNDLER_VERSION
ONBUILD ARG NVM_VERSION
ONBUILD ARG NODE_VERSION
ONBUILD ARG NPM_VERSION
ONBUILD ARG YARN_VERSION
ONBUILD RUN [[ -z "$RUBY_VERSION" ]] && { echo "Arg RUBY_VERSION can't be blank."; exit 1; } || { echo "RUBY_VERSION: $RUBY_VERSION"; };
ONBUILD RUN [[ -z "$RAILS_VERSION" ]] && { echo "Arg RAILS_VERSION can't be blank."; exit 1; } || { echo "RAILS_VERSION: $RAILS_VERSION"; };
ONBUILD RUN [[ -z "$BUNDLER_VERSION" ]] && { echo "Arg BUNDLER_VERSION can't be blank."; exit 1; } || { echo "BUNDLER_VERSION: $BUNDLER_VERSION"; };
ONBUILD RUN [[ -z "$NVM_VERSION" ]] && { echo "Arg NVM_VERSION can't be blank."; exit 1; } || { echo "NVM_VERSION: $NVM_VERSION"; };
ONBUILD RUN [[ -z "$NODE_VERSION" ]] && { echo "Arg NODE_VERSION can't be blank."; exit 1; } || { echo "NODE_VERSION: $NODE_VERSION"; };
ONBUILD RUN [[ -z "$NPM_VERSION" ]] && { echo "Arg NPM_VERSION can't be blank."; exit 1; } || { echo "NPM_VERSION: $NPM_VERSION"; };
ONBUILD RUN [[ -z "$YARN_VERSION" ]] && { echo "Arg YARN_VERSION can't be blank."; exit 1; } || { echo "YARN_VERSION: $YARN_VERSION"; };

ONBUILD RUN echo 'Visit https://rvm.io/rvm/install' && \
  gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
  curl -sSL https://get.rvm.io | bash -s stable && \
  echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc && \
  echo 'rvm_silence_path_mismatch_check_flag=1' >> ~/.rvmrc && \
  echo 'rvm_ignore_gemsets_flag=1' >> ~/.rvmrc && \
  echo 'rvm_project_rvmrc_default=1' >> ~/.rvmrc && \
  source ~/.rvm/scripts/rvm && \
  rvm rvmrc warning ignore allGemfiles && \
  rvm install $RUBY_VERSION && \
  rvm --default use $RUBY_VERSION && \
  gem install rails --version=$RAILS_VERSION -N && \
  gem install bundler --version=$BUNDLER_VERSION --conservative -N

ONBUILD RUN echo 'Visit https://github.com/nvm-sh/nvm#installing-and-updating' && \
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
  nvm install $NODE_VERSION && \
  nvm use $NODE_VERSION && \
  npm install npm@$NPM_VERSION -g && \
  npm install yarn@$YARN_VERSION -g

ONBUILD ARG AROUND_BUILD
ONBUILD RUN /bin/bash -l -c "$AROUND_BUILD"

ONBUILD RUN sudo apt update && sudo apt upgrade -y

ONBUILD RUN lsb_release -a && \
  source ~/.rvm/scripts/rvm && \
  rvm -v && \
  ruby -v && \
  rails -v && \
  bundler -v && \
  export NVM_DIR="$HOME/.nvm" && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" && \
  echo "nvm `nvm -v`" && \
  echo "npm `npm -v`" && \
  echo "node `node -v`" && \
  echo "yarn `yarn -v`"