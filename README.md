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
