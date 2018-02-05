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

> In certain cases you want your container to share the host’s process namespace, basically allowing processes within the container to see all of the processes on the system.

> For example, you could build a container with debugging tools like `strace` or `gdb`, but want to use these tools when debugging processes within the container.

> You can read more [docs.docker.com](https://docs.docker.com/engine/reference/run/#pid-settings-pid)

