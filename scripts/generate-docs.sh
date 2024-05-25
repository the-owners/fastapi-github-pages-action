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
# 4. Caller has set up the following environment variables:
#    1. OPENAPI_JSON_FILEPATH - filepath of existing OpenAPI JSON spec
#    2. OPENAPI_YAML_DIRECTORY - directory to use to create OpenAPI YAML spec
#    3. API_HTML_DOCS_DIRECTORY - directory to use to create API HTML documentation
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
if [[ ! -v OPENAPI_YAML_DIRECTORY ]]
then
    echo "The environment variable 'OPENAPI_YAML_DIRECTORY' was not set"
    exit 1
fi
if [[ ! -v API_HTML_DOCS_DIRECTORY ]]
then
    echo "The environment variable 'API_HTML_DOCS_DIRECTORY' was not set"
    exit 1
fi

# Validate OpenAPI JSON spec exists
if [ ! -f "$OPENAPI_JSON_FILEPATH" ]; then
    echo "Failed to generate API documentation since API spec was not found at $OPENAPI_JSON_FILEPATH"
    exit 1
fi

# Generate OpenAPI YAML spec from the existing JSON
OPENAPI_YAML_FILEPATH="$OPENAPI_YAML_DIRECTORY/openapi.yaml"
mkdir -p $OPENAPI_YAML_DIRECTORY
yq eval \
    -P $OPENAPI_JSON_FILEPATH \
    -o yaml > $OPENAPI_YAML_FILEPATH

# Generate API documentation from the OpenAPI YAML spec
mkdir -p $API_HTML_DOCS_DIRECTORY
npx @redocly/cli build-docs $OPENAPI_YAML_FILEPATH -o \
    "$API_HTML_DOCS_DIRECTORY/docs.html"
