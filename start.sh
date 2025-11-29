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
function gemini_run_ssh {
  build_img
  cd src
  export $(grep -v '^#' .env | xargs)
  cd ..
  docker network create gemini-network
  docker compose up -d gemini_cli
}


function gemini_run {
  cd src
  export $(grep -v '^#' .env | xargs)
  cd ..
  docker network create gemini-network
  docker run --rm -it \
    --name ${CONTAINER_NAME} \
    --network gemini-network \
    --volume "./gemini_config:$CONTAINER_CONFIG" \
    --volume "$DEVDIR:$CONTAINER_HOME/development" \
    --workdir "$CONTAINER_HOME/development" \
    "${GEMINI_SANDBOX_IMG}:${GEMINI_IMG_VERSION}"
  docker network remove gemini-network
}
  

### Parsing command line arguments:
usage="$(basename "$0")
_Flag: None run gemini_cli container
_Flag: --init initialize gemini-cli
_Flag: --nossh run not in ssh modeqW3456
/"

INIT=false
NOSSH=false

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

    case $key in
        -n|--nossh)
            SSH=true
            printf "\nRunning not in ssh mode"
            shift # past argument
        ;;
    esac
done


if $INIT; then
    gemini_init
    gemini_run_ssh
elif $NOSSH; then
    gemini_run
else
    gemini_run_ssh
fi
