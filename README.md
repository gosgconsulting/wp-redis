# WORDPRESS-REDIS
WordPress Docker Image with php-redis installed.

__Note:__ A separate redis server is needed for operation.

## GETTING STARTED
1. Clone this repo.
    ```BASH
    git clone https://github.com/fazalfarhan01/WordPress-Redis.git
    ```

2. cd into the cloned directory.
    ```BASH
    cd WordPress-Redis
    ```

3. copy `env.example` to `.env` and edit the credentials.
    ```BASH
    cp env.example .env
    nano .env
    ```

4. Run using `docker-compose`

    ```BASH
    docker-compose up -d
    ```
    If you are running an `ARM` machine like a Paspberry-Pi, the official version of phpMyAdmin doesn't work as it is available only for `AMD64`. 
    
    To use it on `ARM`, edit the line `39` in [docker-compose.yml](./docker-compose.yml) to what it looks like below.

    ```DOCKER-COMPOSE
    image: arm64v8/phpmyadmin
    ```

## BUILD YOUR OWN
Modify the [Dockerfile](./Dockerfile) as needed and run the following.
```BASH
docker build -t wordpress-redis .
```

## DOCKER HUB
https://hub.docker.com/r/fazalfarhan01/wordpress-redis