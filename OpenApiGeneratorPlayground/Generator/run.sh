#!/bin/bash

./generate.sh ./api.yaml ./Output MyPackageClient clients --clear-output
./generate.sh ./api.yaml ./Output MyPackageServer server
