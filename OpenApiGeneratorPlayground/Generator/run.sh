#!/bin/bash

./generate.sh ./api.yaml ./ClientOutput MyPackageClient.ThisIsTest.ManyOf.Them clients --clear-output --move-models-to-base-package --only-models
./generate.sh ./api.yaml ./ServerOutput MyPackageServer.Another.Test server --clear-output --move-models-to-base-package --only-models

# Want to use without a specific argument? type something random e.g.
# ./generate.sh ./api.yaml ./OutputFolder MyPackage.Generic both --clear-output DISREGARD --only-models
