# Docker container for Chromium

This project implements a Docker container for [Chromium](https://www.chromium.org/Home).

Which is a fork of [the FireFox variant](https://github.com/jlesage/docker-firefox).

Still a work in progress. Works for now (rougly).
I pull the latest version of the chromium image currently, not a specific version.
So it may break in the future (which can be fixed also).

## Building

```bash
docker build -t docker-chromium .
```

## Running

### Create a data directory for the chromium profile data
```bash
mkdir -p /home/username/chromium-data
```

### Run the container
```bash
docker run --rm  --cap-add=SYS_ADMIN  --name=chromium -v /home/username/chromium-data:/config:rw    -p 5800:5800     docker-chromium
```

### Access the container
```
http://your-ip:5800
```