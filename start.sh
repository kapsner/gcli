#!/bin/bash

function build_img {
  cd src
  GEMINI_VER_URL="https://api.github.com/repos/google-gemini/gemini-cli/releases/latest"
  GEMINI_VERSION=$( \
    curl -s ${GEMINI_VER_URL} | \
    jq -r '.tag_name'| \
    awk '{ gsub("[[:alpha:]]", "") ; print $0 }' \
  )
  sed -i -E 's,^GEMINI_IMG_VERSION=".*"$,GEMINI_IMG_VERSION="'"${GEMINI_VERSION}"'",' .env
  export $(grep -v '^#' .env | xargs)
  cd ..

  if $DEV; then
      baseimage="node:trixie-slim"
      imgname="${IMG_NAME}_prep"
  else
      # https://github.com/google-gemini/gemini-cli/blob/576fda18ebf574b325cd4d5236053e998459fb3c/Dockerfile
      baseimage="${GEMINI_SANDBOX_IMG}:${GEMINI_IMG_VERSION}"
      imgname="${IMG_NAME}"
  fi
  printf "\nBASEIMAGE=${baseimage}\n"
  printf "Building ${imgname}\n"
  docker build \
    --build-arg BASEIMAGE="${baseimage}" \
    -f src/Dockerfile \
    -t "${imgname}" .

  if $DEV; then
    mkdir -p src/tmp
    cd src/tmp
    GEM_BRANCH="fix/companion-ssh --single-branch https://github.com/kapsner/gemini-cli"
    git clone --branch $GEM_BRANCH
    cd ../../
    docker build \
      --build-arg BASEIMAGE="${imgname}" \
      -f src/Dockerfile.dev \
      -t "${IMG_NAME}" .
    rm -rf src/tmp
  fi
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
_Flag: --dev run dev-container
_Flag: --nossh run not in ssh modeqW3456
/"

INIT=false
NOSSH=false
DEV=false

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
            NOSSH=true
            printf "\nRunning not in ssh mode"
            shift # past argument
        ;;
    esac

    case $key in
        -d|--dev)
            DEV=true
            printf "\nRunning dev-container"
            shift # past argument
        ;;
    esac
done


dockerfile="Dockerfile"
if $INIT; then
    gemini_init
    gemini_run_ssh
elif $NOSSH; then
    gemini_run
else
    gemini_run_ssh
fi
