#!/bin/bash

./generate.sh ./api.yaml ./ClientOutput MyPackageClient.ThisIsTest.ManyOf.Them clients --clear-output
./generate.sh ./api.yaml ./ServerOutput MyPackageServer.Another.Test server --clear-output
