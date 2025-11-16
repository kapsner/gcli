#!/bin/bash

function build_img {
  cd src
  export $(grep -v '^#' .env | xargs)
  cd ..
  docker build \
    --build-arg GEMINI_SANDBOX_IMG="${GEMINI_SANDBOX_IMG}:${GEMINI_IMG_VERSION}" \
    -f src/Dockerfile \
    -t "$IMG_NAME" .
}

function gemini_init {
  cd src
  source setup.sh
  cd ..
}

# https://github.com/google-gemini/gemini-cli/issues/1696#issuecomment-3006805819
# https://geminicli.com/docs/get-started/deployment/#2-run-in-a-sandbox-dockerpodman
function gemini_run {
  build_img
  cd src
  export $(grep -v '^#' .env | xargs)
  cd ..
  docker network create gemini-network
  if $INIT; then
    docker compose up -d gemini_cli
  else
    docker compose up -d
  fi
}
  

### Parsing command line arguments:
usage="$(basename "$0")
_Flag: None run gemini_cli container
_Flag: --init initialize gemini-cli"

INIT=false

while [[ $# -gt 0 ]]
do
    key="$1"
    echo $key

    case $key in
        -i|--init)
            INIT=true
            printf "\nRunning in init-mode"
            shift # past argument
        ;;
    esac
done


if $INIT; then
    gemini_init
fi
gemini_run
