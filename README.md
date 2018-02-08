# MAndreev_microservices
## Homework 14
#### Insatll docker 
- for `Linux` should use script from [get.docker.com](https://get.docker.com/)

```bash
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
```
- for `OSX` can download from [docker.com](https://download.docker.com/mac/stable/Docker.dmg) or use [Homebrew-Cask](http://caskroom.github.io/)

```bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # Install Homebrew
brew tap caskroom/cask # Install Homebrew-Cask
brew cask install docker # Install docker
```
#### Some docker commands description
```bash
docker version # Show the Docker version information
docker info # Display system-wide information
docker container run hello-world # Run a command in a new container 
docker ps # Show running containers; also works docker container ps
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}" # Show both running and stopped containers; pretty-prints container output using a Go template
docker images # Show all top level images, their repository and tags, and their size.
docker container run -it ubuntu:16.04 /bin/bash # Create ad start new container; --interactive, -i keep STDIN open even if not attached; --tty, -t allocate a pseudo-TTY; bash process whith PID 1 in this container. If you want detach container without kill PID 1 use Ctrl+p, Ctrl+q
docker container start # Start one or more stopped containers 
docker container attach # Attach local standard input, output, and error streams to a running container
docker container create # Create a new container without start
docker container exec -it <u_container_id> bash # Run a command in a running container interactive. 
docker container commit # Create a new image from a container’s changes
docker container rm # Remove one or more containers
docker rmi # Remove one or more images
```

## Homework 15
- create docker host
- create docker image
- work with Docker Hub

#### New GCE project
- create new project `docker-188912`
- init your project 

```bash
gcloud init
```
- use `docker-machine` to create new docker host instance

```bash
docker-machine create --driver google \
 --google-project docker-181710 \
 --google-zone europe-west1-b \
 --google-machine-type g1-small \
 --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
 docker-host
```
- check our docker host

```bash
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER        ERRORS
docker-host   *        google   Running   tcp://35.198.135.189:2376           v18.01.0-ce 
```
- create `Dockerfile`, `mongod.conf`, `db_config`, `start.sh`
- build `reddit` image

```bash
docker build -t reddit:latest .
```
- add firewall rule to open 9292 port

```bash
gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 --priority=65534 \
 --target-tags=docker-machine \
 --description="Allow TCP connections" \
 --direction=INGRESS
```
- run `reddit` container

```bash
docker run --name reddit -d --network=host reddit:latest
```
#### Docker hub registry
- create `docker id`
- login hub.docker.com

```bash
docker login 
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: mcander
Password: 
Login Succeeded
```
> If you use docker on OSX you should click on the docker icon in the menu bar -> preferences -> and I untick "Securely store docker logins in macOS keychain"

> Default registry is [Docker Hub](https://hub.docker.com)

- tag your `reddit` image and push it

```bash
docker tag reddit:latest mcander/otus-reddit:1.0
docker push mcander/otus-reddit:1.0
```

> \* Namespaces

> By default, all containers have the PID namespace enabled. PID namespace provides separation of processes. The PID Namespace removes the view of the system processes, and allows process ids to be reused including pid 1. 

> In certain cases you want your container to share the host’s process namespace, basically allowing processes within the container to see all of the processes on the system.

> For example, you could build a container with debugging tools like `strace` or `gdb`, but want to use these tools when debugging processes within the container.

> You can read more [docs.docker.com](https://docs.docker.com/engine/reference/run/#pid-settings-pid)

## Homework 16
- separate reddit app by components
- run reddit app microservices 
- use [Alpine Linux](https://alpinelinux.org/) like a base image for `comment` and `ui` services

#### Prepare
- move old files to `docker-monolith` directory
- download [microservices.zip](https://github.com/express42/reddit/archive/microservices.zip) and unzip it into `reddit-microservices` directory
- install [Haskell Dockerfile Linter](https://github.com/hadolint/hadolint)
```bash
brew install hadolint
```
- check and prepare docker host
```bash
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER        ERRORS
docker-host   -        google   Running   tcp://35.198.110.167:2376           v18.02.0-ce   
eval $(docker-machine env docker-host)
```

#### Build application
`Reddit-microservices` contains:
- `post-py` post service
- `comment` comment service
- `ui` web interface working with other services

Let's build `reddit-app`
- pull latest mongodb image
```bash
docker pull mongo:latest
```
- build app images
```
 docker build -t mcander/post:1.0 ./post-py
 docker build -t mcander/comment:1.0 ./comment
 docker build -t mcander/ui:1.0 ./ui
```
> UI build start from step 3 because it uses cache from previous comment build

> To create a smaller comment and ui images we can use official Ubuntu 16.04 image [comment Dockerfile](https://raw.githubusercontent.com/Otus-DevOps-2017-11/MAndreev_microservices/docker-3/reddit-microservices/comment/Dockerfile-ubuntu) and [ui Dockerfile](https://raw.githubusercontent.com/Otus-DevOps-2017-11/MAndreev_microservices/docker-3/reddit-microservices/ui/Dockerfile-ubuntu)

Here we can see difference between images
```
docker images
REPOSITORY             TAG                 IMAGE ID            CREATED              SIZE
mongo                  latest              0f57644645eb        3 weeks ago          366MB
mvertes/alpine-mongo   latest              443e7dc9bcd7        5 days ago           110MB
mcander/comment        1.0                 1c2ef9d817b3        3 minutes ago        757MB
mcander/comment        2.0                 0d744ca66591        2 minutes ago        381MB
mcander/comment        3.0                 c81f08a8463f        About a minute ago   122MB
mcander/ui             1.0                 71100825173b        5 minutes ago        764MB
mcander/ui             2.0                 35505dd361e8        22 seconds ago       391MB
mcander/ui             3.0                 0272e3c71600        About a minute ago   130MB
```

> \* Alpine Linux based dockerfiles; using official `ruby:2.2-alpine` image [comment Dockerfile](https://raw.githubusercontent.com/Otus-DevOps-2017-11/MAndreev_microservices/docker-3/reddit-microservices/comment/Dockerfile-alpine) and [ui Dockerfile](https://raw.githubusercontent.com/Otus-DevOps-2017-11/MAndreev_microservices/docker-3/reddit-microservices/ui/Dockerfile-alpine). 
> Also we can use [alpine-based MongoDB image](https://github.com/mvertes/docker-alpine-mongo). And we can create own images based on `Alpine Linux` for ui and comment services, after app build we can delete packages, cache and temp files so we can create images near 50-60mb 

> Next step after build images shuld pull it into docker registry and delete all local images.  

#### Run reddit app
- create app's network
```
docker network creadte reddit_post
```
- create docker volume
```
docker volume create reddit_db
```
- run services
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db  -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post mcander/post:1.0
docker run -d --network=reddit --network-alias=comment mcander/comment:1.0
docker run -d --network=reddit -p 9292:9292 mcander/ui:1.0
```

And we can use different network alias

```
docker run -d --network=reddit --network-alias=reddit_post_db --network-alias=reddit_comment_db  -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=reddit_post --env POST_DATABASE_HOST=reddit_post_db mcander/post:1.0
docker run -d --network=reddit --network-alias=reddit_comment --env COMMENT_DATABASE_HOST=reddit_comment_db mcander/comment:1.0
docker run -d --network=reddit -p 9292:9292 --env COMMENT_SERVICE_HOST=reddit_comment --env POST_SERVICE_HOST=reddit_post mcander/ui:1.0
```
