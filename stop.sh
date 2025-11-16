#!/bin/bash

cd src
export $(grep -v '^#' .env | xargs)
cd ..
docker compose down
docker network remove gemini-network
