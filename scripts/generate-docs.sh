#!/usr/bin/env bash
#
# This script generates ReDoc API documentation
# based on this package's OpenAPI spec.
#
# Pre-requisites:
# 1. yq has been installed, ref: https://github.com/mikefarah/yq
#    - eg. On Linux using snap: `snap install yq`
#    - eg. On Windows using winget: `winget install --id MikeFarah.yq`
# 2. redoc-cli has been installed, ref: https://github.com/Redocly/redoc
#    - eg. `npm install -g @redocly/cli`
# 3. OpenAPI JSON spec has been pre-generated in the provided directory
# 4. Caller has set the following environment variables:
#    1. OPENAPI_JSON_FILEPATH - filepath of existing OpenAPI JSON spec
#    2. API_DOCS_HTML_FILEPATH - filepath to use for generated API docs
set -e

# Validate prerequisites installed
if ! command -v yq &> /dev/null
then
    echo "Failed to convert OpenAPI spec from JSON to YAML since yq was not installed"
    exit 1
fi

if ! command -v redocly &> /dev/null
then
    echo "Failed to generate ReDoc API documentation since @redocly/cli was not installed"
    exit 1
fi

# Validate env vars set
if [[ ! -v OPENAPI_JSON_FILEPATH ]]
then
    echo "The environment variable 'OPENAPI_JSON_FILEPATH' was not set"
    exit 1
fi
if [[ ! -v API_DOCS_HTML_FILEPATH ]]
then
    echo "The environment variable 'API_DOCS_HTML_FILEPATH' was not set"
    exit 1
fi

# Validate OpenAPI JSON spec exists
if [ ! -f "$OPENAPI_JSON_FILEPATH" ]; then
    echo "Failed to generate API documentation since API spec was not found at $OPENAPI_JSON_FILEPATH"
    exit 1
fi

# Generate OpenAPI YAML spec from the existing JSON
OPENAPI_YAML_DIRECTORY=build/tmp/openapi-yaml
OPENAPI_YAML_FILEPATH="$OPENAPI_YAML_DIRECTORY/openapi.yaml"
mkdir -p $OPENAPI_YAML_DIRECTORY
yq eval \
    -P $OPENAPI_JSON_FILEPATH \
    -o yaml > $OPENAPI_YAML_FILEPATH

# Generate API documentation from the OpenAPI YAML spec
API_HTML_DOCS_DIRECTORY="$(dirname "${API_DOCS_HTML_FILEPATH}")"
mkdir -p $API_HTML_DOCS_DIRECTORY
npx @redocly/cli build-docs $OPENAPI_YAML_FILEPATH -o $API_DOCS_HTML_FILEPATH
