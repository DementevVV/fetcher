[![Run Tests](https://github.com/DementevVV/fetcher/actions/workflows/test.yml/badge.svg)](https://github.com/DementevVV/fetcher/actions/workflows/test.yml)

# Fetcher

Fetcher is a command line program that allows you to fetch web pages and save them to disk for later retrieval and browsing.

## Installation

You can use the following Dockerfile to build a container image:

```
$ docker build -t fetcher .
```

## Usage

Once the image has been built, you can run Fetcher in a container using the following command:

```
$ docker run --rm -v /path/to/output:/app/output fetcher [options] <url>
```

For example:
```
$ docker run --rm -v /path/to/output:/app/output fetcher -m https://example.org
```
