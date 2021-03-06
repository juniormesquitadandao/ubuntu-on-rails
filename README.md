# Ubuntu 20.04 on Rails
Dockerfile and docker-compose to build ubuntu image to development with rails

- Install Docker: https://docs.docker.com/get-docker
- Install Docker Compose: https://docs.docker.com/compose/install

## Ex.: New project with name UoR
- Create folder: UoR
- Add "gem: -N" to file: UoR/.gemrc
- Create file: UoR/docker-compose.yml

```yml
version: '3.8'
services:
  app:
    build:
      context: https://raw.githubusercontent.com/juniormesquitadandao/ubuntu-on-rails/20.04/Dockerfile
      args:
        UBUNTU_LOCALE: en_US.UTF-8
        RUBY_VERSION: 3.0.1
        RAILS_VERSION: 6.0.3.4
        NODE_VERSION: 15.3.0
        YARN_VERSION: 1.22.5
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    environment:
      BINDING: 0.0.0.0
    tty: true
    # command: |
    #   bash -lc '
    #     rvm -v
    #     echo "nvm: `nvm -v`"
    #     bunble install
    #     rails s
    #     sidekiq
    #     irb
    #   '
volumes:
  rvm:
  nvm:
```

- Run to check config: docker-compose config
- Run to up in background: docker-compose build
- Run to up in background: docker-compose up -d
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to show bundle: docker-compose run --rm app bash -lc 'bundle -v'
- Run to show node: docker-compose run --rm app bash -lc 'node -v'
- Run to access terminal app: docker-compose exec app bash

```bash
# Create new project with current folder name
rails new .

# Add jquery
yarn add jquery

# Create SQLite databases
rails db:create

# Start server and access in browser: http://localhost:3000
rails s

exit
```

- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm

## Ex.: New project with name UoR and Postgres 13.1
- If you did the previous example and want to keep the same name as the project, run to clean the docker:

```bash
docker-compose down
docker rm -f $(docker ps -qa)
docker volume rm -f $(docker volume ls -q)
docker rmi -f $(docker images -qa)
```

- Create folder: UoR
- Add "gem: -N" to file: UoR/.gemrc
- Create file: UoR/docker-compose.yml

```yml
version: '3.8'
services:
  app:
    build:
      context: https://raw.githubusercontent.com/juniormesquitadandao/ubuntu-on-rails/20.04/Dockerfile
      args:
        UBUNTU_LOCALE: en_US.UTF-8
        RUBY_VERSION: 3.0.1
        RAILS_VERSION: 6.0.3.4
        NODE_VERSION: 15.3.0
        YARN_VERSION: 1.22.5
        AROUND_BUILD: >
          sudo apt update &&
          sudo apt install -y libpq-dev
    working_dir: /home/uor/UoR
    volumes:
      - .:/home/uor/UoR
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
    ports:
      - 3000:3000
    environment:
      BINDING: 0.0.0.0
    depends_on:
      - postgresql
      - redis
    volumes_from:
      - postgresql
    tty: true
    # command: |
    #   bash -lc '
    #     rvm -v
    #     echo "nvm: `nvm -v`"
    #     bunble install
    #     rails s
    #     sidekiq
    #     irb
    #   '
  postgresql:
    image: postgres:13.1
    working_dir: /var/backups/postgresql
    environment:
      POSTGRES_USER: uor
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD_TO_FIRST_UP}
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./uor/postgresql/sockets:/var/run/postgresql
      - ./uor/postgresql/backups:/var/backups/postgresql
  redis:
    image: redis:6.0.9
volumes:
  rvm:
  nvm:
  pg_data:
```

- Run to build and up: POSTGRES_PASSWORD_TO_FIRST_UP=$RANDOM docker-compose up
- Type to exit: CTRL+C
- Run to up in background: docker-compose build
- Run to up in background: docker-compose up -d
- Run to enable permissions on folder "uor": sudo chown $USER:$USER -R uor
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to show bundle: docker-compose run --rm app bash -lc 'bundle -v'
- Run to show node: docker-compose run --rm app bash -lc 'node -v'
- Run to access terminal app: docker-compose exec app bash

```bash
# Create new project with current folder name
rails new . --database=postgresql

# Add jquery
yarn add jquery

# Create Postgresql databases
# Rails auto connect in Postgresql with Unix Socket "/var/run/postgresql/.s.PGSQL.5432" and ubuntu current user "uor" without password
rails db:create

# Add redis gem
bundler add redis

# Start rails console
rails c

# Ping redis
Redis.new(host: 'redis').ping
exit

# Start server and access in browser: http://localhost:3000
rails s

exit
```
- Add "/uor" to file: UoR/.gitignore
- Run to access terminal postgresql: docker-compose exec postgresql bash

```bash
# Create backup and see filder "UoR/uor/postgresql/backups"
pg_dump -d UoR_development -f UoR_development.backup -F c -Z 9 -w -U uor

# Restore backup
pg_restore -d UoR_development UoR_development.backup -O -c --role=uor -U uor

exit
```

- Connect to PGAdmin by Unix Socket without password
- Run: echo "$PWD/uor/postgresql/sockets"
- Example path generated "/home/user/projects/UoR/uor/postgresql/sockets"
- Config connection

```yml
Host: /home/user/projects/UoR/uor/postgresql/sockets
Port: 5432
User: uor
Password:
Maintenance Database: uor
```

- Connect to Dbeaver (Install .deb, snap raise Permission Denied) by Unix Socket without password (https://jdbc.postgresql.org/documentation/head/connect.html)
- Run: echo "$PWD/uor/postgresql/sockets"
- Example path generated "/home/user/projects/UoR/uor/postgresql/sockets"
- Config connection

```txt
- Connection setting -> Server -> Host: /home/user/projects/UoR/uor/postgresql/sockets
- Connection setting -> Server -> Port: 5432
- Connection setting -> Server -> Database: postgres
- Connection setting -> Authentication -> Authentication: Database Native
- Connection setting -> Authentication -> Username: postgres
- Connection setting -> Authentication -> Password:
- Connection setting -> Authentication -> Save Password: true
- Connection setting -> Edit drive settings -> Url template: jdbc:postgresql:[{database}]?socketFactory=org.newsclub.net.unix.socketfactory.PostgresqlAFUNIXSocketFactory&socketFactoryArg={host}/.s.PGSQL.5432
- Connection setting -> Edit drive settings -> Add artifact: Groupid=no.fiken.oss.junixsocket ArtifactId=junixsocket-common
- Connection setting -> Edit drive settings -> Add artifact: Groupid=no.fiken.oss.junixsocket ArtifactId=junixsocket-native-common
- Connection setting -> Test connection
- Connection setting -> PostgreSQL -> Show all databse: true
- General -> Connection Name: l4dy
- Ok
```

- Connect to PGAdmin or Dbeaver by tcp with password
- Add postresql ports in docker-compose.yml

```yml
postgresql:
  ...
  ports:
    - 5432:5432
  ...
```

- Run: docker-compose restart
- Config connection

```yml
Host: localhost
Port: 5432
User: uor
Password: [USER_PASSWORD]
Maintenance Database: uor
```

- Run to access terminal redis: docker-compose exec redis bash

```bash
# Ping redis
redis-cli PING

exit
```

- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect uor_rvm
- Run to show volume nvm: docker volume inspect uor_nvm
- Run to show volume postgres: docker volume inspect uor_pg_data

## Ex.: Migrate existing project with Postgres, incompatibility between ruby and rails, privated gems, and aws
- If you want to clean the docker:

```bash
docker-compose down
docker rm -f $(docker ps -qa)
docker volume rm -f $(docker volume ls -q)
docker rmi -f $(docker images -qa)
```

- Remove file: [project folder]/.ruby-version
- Remove file: [project folder]/.ruby-gemset
- Add "gem: -N" to file: [project folder]/.gemrc
- Create file: [project folder]/docker-compose.yml

```yml
version: '3.8'
services:
  app:
    build:
      context: https://raw.githubusercontent.com/juniormesquitadandao/ubuntu-on-rails/20.04/Dockerfile
      args:
        UBUNTU_LOCALE: en_US.UTF-8
        RUBY_VERSION: [project version]
        RAILS_VERSION: [project version] -f
        NODE_VERSION: [project version]
        YARN_VERSION: [project version]
        AROUND_BUILD: >
          sudo apt update &&
          sudo apt install -y libpq-dev &&
          sudo apt install -y git
    working_dir: /home/uor/[project folder]
    volumes:
      - .:/home/uor/[project folder]
      - rvm:/home/uor/.rvm
      - nvm:/home/uor/.nvm
      - ~/.ssh:/home/uor/.ssh:ro
      - ~/.aws:/home/uor/.aws:ro
    ports:
      - 3000:3000
    environment:
      BINDING: 0.0.0.0
    depends_on:
      - postgresql
      - redis
    volumes_from:
      - postgresql
    tty: true
    # command: |
    #   bash -lc '
    #     rvm -v
    #     echo "nvm: `nvm -v`"
    #     bunble install
    #     rails s
    #     sidekiq
    #     irb
    #   '
  postgresql:
    image: postgres:[project version]
    working_dir: /var/backups/postgresql
    environment:
      POSTGRES_USER: uor
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD_TO_FIRST_UP}
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./uor/postgresql/sockets:/var/run/postgresql
      - ./uor/postgresql/backups:/var/backups/postgresql
  redis:
    image: redis:[project version]
volumes:
  rvm:
  nvm:
  pg_data:
```

- Run to build and up: POSTGRES_PASSWORD_TO_FIRST_UP=$RANDOM docker-compose up
- Type to exit: CTRL+C
- Remove "host" and "password" of "develpment" and "test" in: [project folder]/config/database.yml
- Add "username: uor" to "develpment" and "test" em: [project folder]/config/database.yml
- Run to up in background: docker-compose build
- Run to up in background: docker-compose up -d
- Run to enable permissions on folder "uor": sudo chown $USER:$USER -R uor
- Run to show images: docker images
- Run to show containers: docker ps
- Run to show volumes: docker volume ls
- Run to show bundle: docker-compose run --rm app bash -lc 'bundle -v'
- Run to show node: docker-compose run --rm app bash -lc 'node -v'
- Run to access terminal app: docker-compose exec app bash

```bash
# Install project gems
bundle install

# Install project packages
yarn

# Create Postgresql databases
# Rails auto connect in Postgresql with Unix Socket "/var/run/postgresql/.s.PGSQL.5432" and ubuntu current user "uor" without password
rails db:create db:migrate db:seed

# Start rails console
rails c

# Ping redis
Redis.new(host: 'redis').ping
exit

# Start server and access in browser: http://localhost:3000
rails s

exit
```
- Add "/uor" to file: [project folder]/.gitignore
- Run to access terminal postgresql: docker-compose exec postgresql bash

```bash
# Create backup and see filder "UoR/uor/postgresql/backups"
pg_dump -d [project folder]_development -f [project folder]_development.backup -F c -Z 9 -U uor

# Restore backup
pg_restore -d [project folder]_development [project folder]_development.backup -O -c --role=uor -U uor

exit
```

- Connect to PGAdmin by Unix Socket without password
- Run: echo "$PWD/uor/postgresql/sockets"
- Example path generated "/home/user/projects/UoR/uor/postgresql/sockets"
- Config connection

```yml
Host: /home/user/projects/UoR/uor/postgresql/sockets
Port: 5432
User: uor
Password:
Maintenance Database: uor
```

- Connect to Dbeaver (Install .deb, snap raise Permission Denied) by Unix Socket without password (https://jdbc.postgresql.org/documentation/head/connect.html)
- Run: echo "$PWD/uor/postgresql/sockets"
- Example path generated "/home/user/projects/UoR/uor/postgresql/sockets"
- Config connection

```txt
- Connection setting -> Server -> Host: /home/user/projects/UoR/uor/postgresql/sockets
- Connection setting -> Server -> Port: 5432
- Connection setting -> Server -> Database: postgres
- Connection setting -> Authentication -> Authentication: Database Native
- Connection setting -> Authentication -> Username: postgres
- Connection setting -> Authentication -> Password:
- Connection setting -> Authentication -> Save Password: true
- Connection setting -> Edit drive settings -> Url template: jdbc:postgresql:[{database}]?socketFactory=org.newsclub.net.unix.socketfactory.PostgresqlAFUNIXSocketFactory&socketFactoryArg={host}/.s.PGSQL.5432
- Connection setting -> Edit drive settings -> Add artifact: Groupid=no.fiken.oss.junixsocket ArtifactId=junixsocket-common
- Connection setting -> Edit drive settings -> Add artifact: Groupid=no.fiken.oss.junixsocket ArtifactId=junixsocket-native-common
- Connection setting -> Test connection
- Connection setting -> PostgreSQL -> Show all databse: true
- General -> Connection Name: l4dy
- Ok
```

- Connect to PGAdmin or Dbeaver by tcp with password
- Add postresql ports in docker-compose.yml

```yml
postgresql:
  ...
  ports:
    - 5432:5432
  ...
```

- Run: docker-compose restart
- Config connection

```yml
Host: localhost
Port: 5432
User: uor
Password: [USER_PASSWORD]
Maintenance Database: uor
```

- Run to access terminal redis: docker-compose exec redis bash

```bash
# Ping redis
redis-cli PING

exit
```

- Run to stop: docker-compose down
- Run to show volume rvm: docker volume inspect [project folder]_rvm
- Run to show volume nvm: docker volume inspect [project folder]_nvm
- Run to show volume postgres: docker volume inspect [project folder]_pg_data
