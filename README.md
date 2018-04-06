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
## Homework 17
- work with `docker` networks
- using `docker-compose`
- optimize reddit app `Dockerfile`s to use with `docker-compose`

#### Docker networks
`None` network driver: Disable networking
```bash
docker run --network none --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"
docker exec -ti net_test ifconfig
```
> there is no any interfaces only loopback

`Host` network driver: For standalone containers, remove network isolation between the container and the Docker host, and use the host’s networking directly
```bash
docker run --network host --rm -d --name net_test joffotron/docker-net-tools -c "sleep 100"docker exec -ti net_test ifconfig
docker-machine ssh docker-host ifconfig

```
> same commands output; when we try to run `nginx` containers several times `docker run --network host -d nginx` previous container has en error `bind() to 0.0.0.0:80 failed (98: Address already in use)` so that address already in use

We can exec commands in different net namespaces
```bash
# docker host commands
sudo ln -s /var/run/docker/netns /var/run/netns
sudo ip netns # show avaliable net ns
  998a273b14f3 (id: 3)
  7fb39007ca84 (id: 2)
  371c26d3aca0 (id: 1)
  563684341f4d (id: 0)
  default

 ip netns exec <namespace> <command>
```

`bridge` network driver: The default network driver. If you don’t specify a driver, this is the type of network you are creating. Bridge networks are usually used when your applications run in standalone containers that need to communicate. See bridge networks.

- crete bridge network
```bash
docker network create reddit --driver bridge
```
- run `reddit app`. Need to use container name or network aliases
```bash
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post mcander/post:1.0
docker run -d --network=reddit --network-alias=comment mcander/comment:1.0
docker run -d --network=reddit -p 9292:9292 mcander/ui:1.0
```
- run `reddit app` with front and back networks.
```bash
docker kill $(docker ps -q) # stop old containers
# create two networks
docker network create back_net —subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24
# run application
docker run -d --network=front_net -p 9292:9292 --name ui mcander/ui:1.0
docker run -d --network=back_net --name comment mcander/comment:1.0
docker run -d --network=back_net --name post mcander/comment:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
# connect post and connetct containers to front_net
docker network connect front_net post
docker network connect front_net comment
```
- \* inspect networks condition
 Interesting post about docker networks [here](https://habrahabr.ru/post/333874/)

#### Docker compose
Build and run `reddit app` with `docker-compose`
- create docker compose file. here I'm using:
 - `container_name` to see app version. Now it is static, but we can use for explain like `ui-${branchName}-${commitId}-build-${buildNumber}`
 - front/back networks with network aliases for containers
 - logging (idk why maybe i have alot of free time). Im using swarm for ELK deploy. Thanks to [Jérôme Petazzoni](https://github.com/jpetazzo). Its only example.
 ```bash
 docker stack deploy elk -c elk.yml
 ```
 - `command` and `entrypoint` to make `Dockerfile` easy without excess layers
- create `.env` with variables for `docker-compose.yml`
- run `reddit app` using `COMPOSE_PROJECT_NAME`
```bash
docker-compose -p reddit-app- up -d
```
> also can use docker-compose.override.yml to:
 - change app code. I think every docker image is a unique build result, so to change app code we just need to change image `TAG`. If we talk about versioning. Every build we can do unique compose file with ENVs for that build.
 ```bash
docker-compose config > docker-compose-${TAG}.yml
 ```
 now we have unique compose file with static ENVs
 - run debug `puma` with two workers

## Homework 19
- deploy `Gitlab CI` at `GCP`
- create example repo for `reddit app`
- describe CI pipeline
- mass Gitlab CI Runner register
- add `Slack` integration

#### Deploy `Gitlab CI`
- Create instance
```bash
docker-machine create --driver google \                                           
 --google-project docker-188912 \
 --google-zone europe-west1-b \
 --google-machine-type n1-standard-1 \
 --google-disk-size 100 \                                                                  
 --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \ 
 --google-tags 'default-allow-ssh, docker-machine, http-server, https-server'
 gitlab
 ```
- Prepare env
```
docker-machine ssh gitlab
sudo su
apt install docker-compose -y
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
cd /srv/gitlab/
cat <<EOF > docker-compose.yml
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://35.187.28.115'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
EOF
docker-compose up -d
```
- open http://35.187.28.115/ and set new `root` password
- login into Gitlab and disable `Sing-up` (Admin Area\Settings\Sing-up Restrictions)

#### Create example repo for `reddit app`
- create new group `Homework` and create new project `example`
- add git remote Gitlab
```bash
git checkout -b docker-6
git remote add gitlab http://35.187.28.115/homework/example.git
git push gitlab docker-6
```
- create `.gitlab-ci.yml`
- add runner
 - get token (`example` Settings\CI/CD\Runner settings\Expand)
 - run `gitlab-runner` container
 ```
 eval $(docker-machine env gitlab)
 docker run -d --name gitlab-runner --restart always \
   -v /srv/gitlab-runner/config:/etc/gitlab-runner \
   -v /var/run/docker.sock:/var/run/docker.sock \
   gitlab/gitlab-runner:latest
 ```
 - register `gitlab-runner`.
 ```
 docker exec -it gitlab-runner gitlab-runner register
 http://35.187.28.115 # url
 `token` # token
 my-runner # description
 linux,xenial,ubuntu,docker # tags
 true # untagged builds
 false # lock for current project
 docker # executor
 alpine:latest # docker image
 ```
- add reddit app
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab docker-6
```
- add [simpletest.rb](https://gist.github.com/Nklya/d70ff7c6d1c02de8f18bcd049e904942) to `reddit` dir

#### Mass Gitlab CI Runner register
I have found [Runners autoscale](https://docs.gitlab.com/runner/configuration/autoscale.html) and [how to install and config them](https://docs.gitlab.com/runner/install/autoscaling.html)

#### Add `Slack` integration
- [Here](https://devops-team-otus.slack.com/services/B7MQ8N610) get webhook url
- Add webhook to Gitlab Project Settings > Integrations > Slack notifications
![Imgur](https://i.imgur.com/bBpkJFx.jpg)

## Homework 20
- Create Gitalab pipeline for Stage and Prod envs
- Add dynamic envs with stop button

## Homework 21
- prepare env
- build images
- add prometheus and mode-exporter to docker-compose.yml
- run and check services availability

#### Prepare env
- add firewall rules
```bash
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```
- create Docker host
```bash
export GOOGLE_PROJECT=docker-188912
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    vm1
eval $(docker-machine env vm1)
```
- build `reddit-app` images
```bash
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```


#### Prepare Prometheus
- create `Dockerfile` in `monitoring/prometheus`
- add Prometheus to `docker-compose.yml`
- add config to collect app's metrics `monitoring/prometheus/prometheus.yml`

#### Add Node exporter, MongoDB exporter, Blackbox exporter
- build [Blackbox exporter](https://github.com/prometheus/blackbox_exporter/blob/master/Dockerfile)
- use [MongoDB exporter](https://hub.docker.com/r/targetprocess/mongodb_exporter/)
- add Node exporter, MongoDB exporter, Blackbox exporter to `docker-compose.yml` and `prometheus.yml`
- build Prometheus image
```bash
export USER_NAME=mcander
docker build -t $USER_NAME/prometheus .
```
- tag MongoDB exporter, Blackbox exporter
```bash
for i in mongodb blackbox; do docker tag ${USER_NAME}/$i_exporter:latest ${USER_NAME}/$i_exporter:v1.0; done
```

#### Push images
```bash
docker login
for i in ui post-py comment prometheus; do docker push ${USER_NAME}/$i; done
for i in mongodb blackbox; do docker push ${USER_NAME}/$i:v1.0; done
```
#### Use docker compose
```bash
cd docker/
docker-compose up -d # run app with Prometheus
docker-compose down 
docker-machine rm vm1 # delete vm1
```
## Homework 23
- Docker container monitoring
- Metrics visualization
- Collect application and business metrics
- Allerting
docker hub: https://hub.docker.com/u/mcander/

## Homework 25
- Add monitoring and trace services Elasticsearch, Fluentd, Kibana, Zipkin
- Using grog parsing for fluentd
- Change some compose files and add sript to up and down docker networks

```bash
docker-compose -f docker-compose-logging.yaml up -d --build
docker-compose up
```
