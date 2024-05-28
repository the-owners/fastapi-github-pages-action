### Testing

#### Prerequisites

1. jq has been installed, ref: https://jqlang.github.io/jq/download/
2. gh has been installed, ref: https://github.com/cli/cli#installation
   - Once installed, set up your credentials via `gh auth login`
3. yq has been installed, ref: https://github.com/mikefarah/yq
4. redoc-cli has been installed, ref: https://github.com/Redocly/redoc
   - eg. `npm install -g @redocly/cli`

#### Validating API doc generation locally

* Run `./test/test-multi-branch-doc-generation.sh`.
* Validate succeeds and can open the following API docs in a web browser:
  * `docs/test/docs.html`
  * `docs/v1/docs.html`
  * `docs/v2/docs.html`
