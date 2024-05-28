#!/usr/bin/env bash
#
# This script generates ReDoc API documentation
# based on this package's OpenAPI specs.
#
# Pre-requisites:
# 1. jq has been installed, ref: https://jqlang.github.io/jq/download/
# 2. yq has been installed, ref: https://github.com/mikefarah/yq
#    - eg. On Linux using snap: `snap install yq`
#    - eg. On Windows using winget: `winget install --id MikeFarah.yq`
# 3. redoc-cli has been installed, ref: https://github.com/Redocly/redoc
#    - eg. `npm install -g @redocly/cli`
# 4. OpenAPI JSON spec has been pre-generated in the provided directory
# 5. Caller has set the following environment variables:
#    1. API_CONFIGS - JSON string configuring API generation for each OpenAPI spec
#    2. API_DOCS_DIR - parent directory to use for generated API docs
set -e

# Validate prerequisites installed
if ! command -v jq &> /dev/null
then
    echo "Failed to parse JSON since jq was not installed"
    exit 1
fi

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
if [[ ! -v API_CONFIGS ]]
then
    echo "The environment variable 'API_CONFIGS' was not set"
    exit 1
fi
if [[ ! -v API_DOCS_DIR ]]
then
    echo "The environment variable 'API_DOCS_DIR' was not set"
    exit 1
fi

# Save original directory so can later cd back when relative filepaths matter
export ORIGINAL_DIR=$(pwd)

# Fetch all Git branch references to enable checking out files from any branch
git fetch --all

# Create empty API docs directory if does not exist
mkdir -p $API_DOCS_DIR

# Infer script directory regardless of how script was invoked
# Ref: https://stackoverflow.com/a/53122736
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

apiConfigsSplitToOnePerLine=$(echo $API_CONFIGS | jq -c .[])
for apiConfig in $apiConfigsSplitToOnePerLine
do
    cd $ORIGINAL_DIR
    echo "Running script to generate API docs for config: $apiConfig"
    source $script_dir/generate-single-spec-doc.sh $apiConfig
done

# Return to original directory for subsequent actions
cd $ORIGINAL_DIR
