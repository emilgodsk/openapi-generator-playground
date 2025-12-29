OUTPUT_FOLDER=./Output

# Reset the folder
rm -rf $OUTPUT_FOLDER

# Create the folder with the .openapi-generator-ignore file
mkdir $OUTPUT_FOLDER
cp .openapi-generator-ignore $OUTPUT_FOLDER

# Generate the code
openapi-generator-cli generate \
  -i ./api.yaml \
  -g csharp \
  -o $OUTPUT_FOLDER \
  --additional-properties=sourceFolder=./,packageName=MyPackageClient,library=generichost,targetFramework=net10.0,optionalProjectFile=false,nullableReferenceTypes=true,optionalEmitDefaultValues=true

openapi-generator-cli generate \
  -i ./api.yaml \
  -g aspnetcore \
  -o $OUTPUT_FOLDER \
  -t ./Templates/aspnetcore \
  --additional-properties=sourceFolder=./,packageName=MyPackageServer,buildTarget=library,useNewtonsoft=false,useSwashbuckle=false,nullableReferenceTypes=true,isLibrary=true,pocoModels=true


# Clean up unnecessary files
rm -rf $OUTPUT_FOLDER/.openapi-generator
rm $OUTPUT_FOLDER/.openapi-generator-ignore
rm -rf $OUTPUT_FOLDER/**/OpenApi
rm -rf $OUTPUT_FOLDER/**/Converters
rm -rf $OUTPUT_FOLDER/**/Authentication
rm -rf $OUTPUT_FOLDER/**/Formatters
rm -rf $OUTPUT_FOLDER/**/Attributes
rm -rf $OUTPUT_FOLDER/**/Extensions
