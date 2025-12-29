
# Notes

Run via generate.sh script.
- Requires openapi-generator-cli installed. See https://openapi-generator.tech/docs/installation

Generator/Output is auto-generated via the script and is deleted and recreated everytime the script is run.

You can retrieve the mustache templates used by OpenApiGenerator by running the following command:

```bash
openapi-generator-cli author template -g aspnetcore
```

Then you can specify via the `-t` argument the path to the templates when generating code
You only have to override the templates you want to change.

It generates a lot of useless files. Most of them can be ignored via the .openapi-generator-ignore file. However, some files cannot be ignored that way, so I am deleting those in the generate.sh script after generation.
