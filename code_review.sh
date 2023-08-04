#!/bin/bash

PACKAGE=
API_KEY=
DIR_PATH=

show_help() {
cat <<EOF
Usage: ${0##*/} [-k API_KEY] [-d DIR_PATH] PACKAGE

This script performs various checks on a specified package, including
running cargo check, cargo clippy, cargo fmt, and scanning the code for
"TODO" or "FIXME" comments. Finally, it submits the code to a GPT-based 
code review API.

Options:
  -h, --help                 Show this help text and exit
  -k, --api-key API_KEY      Set the API key for the GPT-based code review API
  -d, --dir-path DIR_PATH    Set the directory path for the code to be reviewed
EOF
}

abort() {
  echo "$1" >&2
  exit 1
}

while test $# -gt 0; do
  case "$1" in
    -h | --help)
      show_help
      exit 0
      ;;
    -k | --api-key)
      shift
      [ $# -gt 0 ] || abort "No API key provided"
      API_KEY=$1
      shift
      ;;
    -d | --dir-path)
      shift
      [ $# -gt 0 ] || abort "No directory path provided"
      DIR_PATH=$1
      shift
      ;;
    *)
      [ -z "${PACKAGE}" ] || abort "Package already specified: $PACKAGE"
      PACKAGE=$1
      shift
      ;;
  esac
done

[ -n "${PACKAGE}" ] || abort "No package specified"
[ -n "${API_KEY}" ] || abort "No API key specified"
[ -n "${DIR_PATH}" ] || abort "No directory path specified"

run_cargo_command() {
  echo "Running cargo $1 for $PACKAGE"
  cargo "$1" --package "$PACKAGE" || abort "cargo $1 failed"
}

check_todos_and_fixmes() {
  echo "Checking for TODOs and FIXMEs in $PACKAGE"
  rg -n -i -e "TODO" -e "FIXME" src || echo "No TODOs or FIXMEs found"
}

run_code_review() {
  echo "Running GPT-based code review for $PACKAGE"

  # OpenAI's API endpoint
  local ENDPOINT="https://api.openai.com/v1/chat/completions"

  # Initialize CODE variable
  local CODE=""

  # Loop over all .rs files in the directory and its subdirectories
  while IFS= read -r -d '' CODE_PATH; do
    # Check if the code file exists
    [ -f "${CODE_PATH}" ] || abort "Code file does not exist: $CODE_PATH"

    # Read the code into a variable and concatenate it with previous files
    CODE+="$(<"$CODE_PATH")"
    CODE+=$'\n\n' # add two newlines as a separator between files
  done < <(find "$DIR_PATH" -name '*.rs' -print0)

  # Generate POST data for API request
  generate_post_data() {
    cat <<EOF
    {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": "This is a code review assistant."},
        {"role": "user", "content": "Please review the following Rust code: $CODE"}
      ]
    }
EOF
  }

  # Make the API request
  local REVIEW=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $API_KEY" -d "$(generate_post_data)" "$ENDPOINT")

  # Print the review
  echo "$REVIEW"
}

run_cargo_command check
run_cargo_command clippy
run_cargo_command fmt
check_todos_and_fixmes
run_code_review