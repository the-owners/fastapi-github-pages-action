export API_CONFIGS='[{
  "branch": "main",
  "openapi-json-filepath": "test/resources/openapi.json",
  "api-doc-filepath": "test/docs.html"
},
{
  "branch": "v1",
  "openapi-json-filepath": "test/resources/openapi.json",
  "api-doc-filepath": "v1/docs.html"
},
{
  "branch": "v2",
  "openapi-json-filepath": "test-resources/openapi.json",
  "api-doc-filepath": "v2/docs.html"
}]'
export API_DOCS_DIR='docs'

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/../scripts/generate-docs.sh
