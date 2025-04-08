const fs = require('fs');
const path = require('path');

function parseArguments() {
  const args = process.argv.slice(2);
  let inputJson, outputHtml;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '-o' || args[i] === '--output') {
      outputHtml = args[i + 1];
      i++;
    } else if (args[i].endsWith('.json')) {
      inputJson = args[i];
    } else if (args[i].endsWith('.html')) {
      outputHtml = args[i];
    }
  }

  if (!inputJson) {
    console.error('Error: No input JSON file specified');
    process.exit(1);
  }

  if (!outputHtml) {
    outputHtml = inputJson.replace('.json', '.min.html');
    console.log(`ℹ️ No output specified, using default: ${outputHtml}`);
  }

  return { inputJson, outputHtml };
}

async function minifyBuild() {
  const { inputJson, outputHtml } = parseArguments();

  try {
    console.log(`⚡ Processing ${inputJson} → ${outputHtml}`);
    
    // 1. Load and minify JSON
    const jsonContent = JSON.parse(fs.readFileSync(inputJson, 'utf8'));
    const minifiedJson = JSON.stringify(jsonContent);
    
    // 2. Create basic HTML structure with the API reference
    const htmlTemplate = `
<!doctype html>
<html>
  <head>
    <title>Tollsys API Reference — Scalar</title>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1" />
      <style>
        :root {
          --scalar-custom-header-height: 50px;
        }
        .custom-header {
          height: var(--scalar-custom-header-height);
          background-color: var(--scalar-background-1);
          box-shadow: inset 0 -1px 0 var(--scalar-border-color);
          color: var(--scalar-color-1);
          font-size: var(--scalar-font-size-2);
          padding: 0 18px;
          position: sticky;
          justify-content: space-between;
          top: 0;
          z-index: 100;
        }
        .custom-header,
        .custom-header nav {
          display: flex;
          align-items: center;
          gap: 18px;
        }
        .custom-header a:hover {
          color: var(--scalar-color-2);
        }
      </style>
  </head>

  <body>
    <header class="custom-header scalar-app">
      <b>Tollsys Backend API Reference</b>
      <nav>
        <a href="https://github.com/the-owners/tollsys-backend">GitHub</a>
      </nav>
    </header>
    <!-- Initialize the Scalar API Reference -->
    <script
      id="api-reference"
      data-proxy-url="https://proxy.scalar.com"
      type="application/json">
      ${minifiedJson}
    </script>
    <script>
      var configuration = {
        theme: 'default',
        hideClientButton: true,
        hideTestRequestButton: true,
        servers: [
          {
            url: 'http://locahost:8000',
          },
        ],
        metaData: {
          title: 'Tollsys',
        }
      };

      document.getElementById('api-reference').dataset.configuration =
        JSON.stringify(configuration);
    </script>

    <!-- Load the Script -->
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>
  </body>
</html>`;

    // 3. Minify HTML
    const minifiedHtml = htmlTemplate
      .replace(/\s+/g, ' ')
      .replace(/>\s+</g, '><')
      .trim();

    // 4. Ensure output directory exists
    const outputDir = path.dirname(outputHtml);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // 5. Save to file
    fs.writeFileSync(outputHtml, minifiedHtml);
    
    const originalSize = Buffer.byteLength(htmlTemplate, 'utf8') / 1024;
    const minifiedSize = Buffer.byteLength(minifiedHtml, 'utf8') / 1024;
    
    console.log('✅ Success! Minified build created');
    console.log(`📦 Original: ${originalSize.toFixed(2)} KB`);
    console.log(`✨ Minified: ${minifiedSize.toFixed(2)} KB (${Math.round((1 - minifiedSize/originalSize) * 100)}% reduction)`);
    
  } catch (error) {
    console.error('🚨 Error:', error.message);
    process.exit(1);
  }
}

minifyBuild();