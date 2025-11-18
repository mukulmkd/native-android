#!/bin/bash
# Generate autolinking.json from react-native config

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JS_DIR="$PROJECT_ROOT/js"
OUTPUT_FILE="$PROJECT_ROOT/build/generated/autolinking/autolinking.json"

# Create output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Generate config from react-native
cd "$JS_DIR"
npx react-native config 2>&1 | python3 -c "
import sys
import json

try:
    data = json.load(sys.stdin)
    output = {
        'dependencies': data.get('dependencies', {}),
        'project': data.get('project', {})
    }
    print(json.dumps(output, indent=2))
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" > "$OUTPUT_FILE"

echo "Generated autolinking config at: $OUTPUT_FILE"

