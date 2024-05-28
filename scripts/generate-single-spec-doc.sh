#!/usr/bin/env bash
#
# This script generates ReDoc API documentation
# for a given OpenAPI JSON spec file.
#
# Pre-requisites:
# 1. jq has been installed, ref: https://jqlang.github.io/jq/download/
# 2. yq has been installed, ref: https://github.com/mikefarah/yq
#    - eg. On Linux using snap: `snap install yq`
#    - eg. On Windows using winget: `winget install --id MikeFarah.yq`
# 3. redoc-cli has been installed, ref: https://github.com/Redocly/redoc
#    - eg. `npm install -g @redocly/cli`
set -e

apiConfig=$(echo $1 | jq)

branchToFetchApiSpecFrom=$(echo $apiConfig | jq -r .branch)
openApiJsonFilepath=$(echo $apiConfig | jq -r .\"openapi-json-filepath\")
apiDocFilepath=$(echo $apiConfig | jq -r .\"api-doc-filepath\")

# Validate required config parameters
if [ "${openApiJsonFilepath}" = "null" ]; then
    echo "Failed to generate API doc since missing openapi-json-filepath in API config '$apiConfig'"
    exit 1
fi
if [ "${apiDocFilepath}" = "null" ]; then
    echo "Failed to generate API doc since missing api-doc-filepath in API config '$apiDocFilepath'"
    exit 1
fi

# Fetch OpenAPI JSON spec if provided branch config
cd $WORKSPACE_DIR
if [ "${branchToFetchApiSpecFrom}" = "null" ]; then
    echo "No Git branch provided for API spec, falling back to local directory"
else
    echo "Fetching API spec file $openApiJsonFilepath from branch $branchToFetchApiSpecFrom"
    git checkout $branchToFetchApiSpecFrom -- $openApiJsonFilepath
fi

# Validate OpenAPI JSON spec exists
if [ ! -f "$openApiJsonFilepath" ]; then
    echo "Failed to generate API documentation since API spec was not found at $openApiJsonFilepath"
    exit 1
fi

# Generate OpenAPI YAML spec from the existing JSON
openApiYamlDir="$WORKSPACE_DIR/build/tmp/openapi-yaml"
openApiYamlFilepath="$openApiYamlDir/openapi.yaml"
mkdir -p $openApiYamlDir
echo "Converting OpenAPI JSON spec file $openApiJsonFilepath to YAML"
yq eval -P $openApiJsonFilepath -o yaml > $openApiYamlFilepath
echo "Successfully generated OpenAPI YAML spec file at $openApiYamlFilepath"

# Generate API documentation from the OpenAPI YAML spec
fullyQualifiedApiFilepath="$WORKSPACE_DIR/$API_DOCS_DIR/$apiDocFilepath"
apiFileDir=$(dirname $fullyQualifiedApiFilepath)
mkdir -p $apiFileDir
echo "Generating ReDoc API docs at $fullyQualifiedApiFilepath"
npx @redocly/cli build-docs $openApiYamlFilepath -o $fullyQualifiedApiFilepath

if [ ! -f "$fullyQualifiedApiFilepath" ]; then
    echo "Failed to generate API documentation, generated doc not found at $fullyQualifiedApiFilepath"
    exit 1
else
    echo "Successfully generated API documentation at $fullyQualifiedApiFilepath"
fi
