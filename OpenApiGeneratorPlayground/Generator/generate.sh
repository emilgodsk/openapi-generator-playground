#!/bin/bash

if [ $# -lt 4 ]; then
  echo "Usage: $0 <input-spec-file> <output-folder> <client-package-name> <type-of-generation: clients|server|both> [--clear-output] [--move-models-to-base-package] [--only-models] [--use-namespace-for-models]"
  exit 1
fi

# setopt extendedglob

OUTPUT_FOLDER=$2/tmp
REAL_OUTPUT_FOLDER=$2
PACKAGE_NAME=$3
CLIENT_PACKAGE=$PACKAGE_NAME
SERVER_PACKAGE=$PACKAGE_NAME
INPUT_SPEC_FILE=$1
TYPE_OF_GENERATION=$4
CLEAR_OUTPUT=$5

echo "Generating the OpenAPI code..."

echo " - Using output folder: $REAL_OUTPUT_FOLDER"

if [ "$CLEAR_OUTPUT" = "--clear-output" ]; then
  echo " - Resetting the output folder..."
  # Reset the folder
  rm -rf $REAL_OUTPUT_FOLDER
fi

echo " - Creating the output folder..."
# Create the folder with the .openapi-generator-ignore file
mkdir -p $OUTPUT_FOLDER
cp .openapi-generator-ignore $OUTPUT_FOLDER

# The csharp generator and aspnetcore generator do not support generating both client and server code in one go,
# so we need to run the generator twice: once for the client and once for the server

if [ "$TYPE_OF_GENERATION" = "clients" ] || [ "$TYPE_OF_GENERATION" = "both" ]; then
##### CLIENT GENERATION #####

MODEL_PACKAGE=Models
if [ "$6" = "--move-models-to-base-package" ] || [ "$8" = "--use-namespace-for-models" ]; then
  MODEL_PACKAGE="${CLIENT_PACKAGE##*.}"
  CLIENT_PACKAGE="${CLIENT_PACKAGE%.*}"
fi

echo " - Generating the client code..."
# Generate the client: all that is needed (we capture into /dev/null to avoid cluttering the output)
(NODE_OPTIONS="--no-deprecation" openapi-generator-cli generate \
  -i $INPUT_SPEC_FILE \
  -g csharp \
  -o $OUTPUT_FOLDER \
  -t ./Templates/csharp \
  --additional-properties=sourceFolder=./,packageName=$CLIENT_PACKAGE,library=generichost,targetFramework=net8.0,optionalProjectFile=false,nullableReferenceTypes=true,optionalEmitDefaultValues=true,modelPackage=$MODEL_PACKAGE,clientPackage=Common,apiPackage=ApiClients,validatable=false,useDateTimeOffset=true \
  2>&1 1>/dev/null) | cat

echo " - Cleaning up generated files..."
rm -rf $OUTPUT_FOLDER/$CLIENT_PACKAGE/Extensions #Extension methods not very valuable

if [ "$8" = "--use-namespace-for-models" ]; then
  echo " - Adjusting namespaces for models..."
  mv $OUTPUT_FOLDER/$CLIENT_PACKAGE/$MODEL_PACKAGE $OUTPUT_FOLDER/$CLIENT_PACKAGE/Models
fi

if [ "$6" = "--move-models-to-base-package" ]; then
  echo " - Moving models to base package..."
  mv $OUTPUT_FOLDER/$CLIENT_PACKAGE/$MODEL_PACKAGE/* $OUTPUT_FOLDER/$CLIENT_PACKAGE/
  rm -d $OUTPUT_FOLDER/$CLIENT_PACKAGE/$MODEL_PACKAGE
fi

if [ "$7" = "--only-models" ]; then
  echo " - Removing non-model files..."
  rm -rf $OUTPUT_FOLDER/$CLIENT_PACKAGE/Common/ApiFactory.cs
  rm -rf $OUTPUT_FOLDER/$CLIENT_PACKAGE/Common/HostConfiguration.cs
  rm -rf $OUTPUT_FOLDER/$CLIENT_PACKAGE/ApiClients
fi

mv $OUTPUT_FOLDER/$CLIENT_PACKAGE/* $REAL_OUTPUT_FOLDER/

fi

if [ "$TYPE_OF_GENERATION" = "server" ] || [ "$TYPE_OF_GENERATION" = "both" ]; then
##### SERVER GENERATION #####
echo " - Generating the models for the server..."

MODEL_PACKAGE=Models
if [ "$6" = "--move-models-to-base-package" ] || [ "$8" = "--use-namespace-for-models" ]; then
  MODEL_PACKAGE="${SERVER_PACKAGE##*.}"
  SERVER_PACKAGE="${SERVER_PACKAGE%.*}"
fi

# To generate the server: we need to use aspnetcore generator + the csharp models
# This generates the models from the csharp generator
# (we capture into /dev/null to avoid cluttering the output)
(NODE_OPTIONS="--no-deprecation" openapi-generator-cli generate \
  -i $INPUT_SPEC_FILE \
  -g csharp \
  -o $OUTPUT_FOLDER \
  -t ./Templates/csharp \
  --additional-properties=sourceFolder=./,packageName=$SERVER_PACKAGE,library=generichost,targetFramework=net8.0,optionalProjectFile=false,nullableReferenceTypes=true,optionalEmitDefaultValues=true,modelPackage=$MODEL_PACKAGE,clientPackage=Common,apiPackage=ApiClients,validatable=false,useDateTimeOffset=true \
  2>&1 1>/dev/null) | cat

echo " - Generating the server code..."
# Now we generate the controller (we capture into /dev/null to avoid cluttering the output)
(NODE_OPTIONS="--no-deprecation" openapi-generator-cli generate \
  -i $INPUT_SPEC_FILE \
  -g aspnetcore \
  -o $OUTPUT_FOLDER \
  -t ./Templates/aspnetcore \
  --additional-properties=sourceFolder=./,packageName=$SERVER_PACKAGE,buildTarget=library,useNewtonsoft=false,useSwashbuckle=false,nullableReferenceTypes=true,isLibrary=true,pocoModels=true,useSeparateModelProject=true \
  2>&1 1>/dev/null) | cat

echo " - Cleaning up generated files..."
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/ApiClients
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE.Models
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Common/ApiFactory.cs
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Common/HostConfiguration.cs
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/OpenApi #Swashbuckle specific folder
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Authentication #OpenAPI Authentication not used
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Formatters #InputFormatterStream unused
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Attributes #ValidateModelStateAttribute unused
rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Extensions #Extension methods not very valuable

if [ "$8" = "--use-namespace-for-models" ]; then
  echo " - Adjusting namespaces for models..."
  mv $OUTPUT_FOLDER/$SERVER_PACKAGE/$MODEL_PACKAGE $OUTPUT_FOLDER/$SERVER_PACKAGE/Models
fi

if [ "$6" = "--move-models-to-base-package" ]; then
    echo " - Moving models to base package..."
    mv $OUTPUT_FOLDER/$SERVER_PACKAGE/$MODEL_PACKAGE/* $OUTPUT_FOLDER/$SERVER_PACKAGE/
    rm -d $OUTPUT_FOLDER/$SERVER_PACKAGE/$MODEL_PACKAGE
fi

if [ "$7" = "--only-models" ]; then
  echo " - Removing non-model files..."
  rm -rf $OUTPUT_FOLDER/$SERVER_PACKAGE/Controllers
fi

mv $OUTPUT_FOLDER/$SERVER_PACKAGE/* $REAL_OUTPUT_FOLDER/

fi

#### CLEANUP GENERATED FILES #####
echo " - Cleaning up extra generated files..."

# Clean up unnecessary files
#rm -rf $REAL_OUTPUT_FOLDER/.openapi-generator

rm -rf $OUTPUT_FOLDER

echo "[✓] OpenAPI code generation completed."
