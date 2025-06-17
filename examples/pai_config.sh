if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be included, not executed directly."
    exit 1
fi

# Where are the pai files located?
PAI_DIR="$PWD"

# Where is your code located?
CODE_DIR="/home/mozrin/Code/orchard"

# What do you want your input and output files called?
#
# nb: If you change something here, you will need to update your .gitignore
OUTPUT_FILE="$PAI_DIR/pai.output.txt"
PROMPT_FILE="$PAI_DIR/pai.prompt.txt"
DETAILS_FILE="$PAI_DIR/pai.details.txt"

# DART EXAMPLE
EXCLUDE_FILES="nothing.txt"
EXCLUDE_DIRS="build|ios|android|.dart_tool|.git|web|macos|windows|linux|packages|images|temp|test|test_driver"
INCLUDE_EXTS="dart|yaml|json"
ROOT_FOLDERS="$PAI_DIR/../assets|$PAI_DIR/../lib"

# LARAVEL EXAMPLE
# EXCLUDE_FILES="package-lock.json|composer-lock.json|0001_01_09_000001_create_permission_tables.php"
# EXCLUDE_DIRS="vendor|node_modules|cache|tests|framework|logs|console"
# INCLUDE_EXTS="php|json|yml"