# Rust Package Review Script

This script performs various checks on a specified Rust package, including running `cargo check`, `cargo clippy`, and `cargo fmt`. Additionally, it scans the code for "TODO" or "FIXME" comments. The last part of the script submits the code to a GPT-based code review API for automated code review.

## Dependencies

The script depends on the following tools:
- `cargo`: The Rust package manager. The script assumes that `cargo` and its associated tools (`check`, `clippy`, and `fmt`) are installed and available in the PATH.
- `curl`: Used to make the HTTP request to the code review API.
- `rg` (ripgrep): Used to search for "TODO" and "FIXME" comments in the code.

Make sure these tools are installed and configured properly on your system.

## Usage

Run the script using the following command:

```bash
./script.sh -k your-api-key -d your-dir-path your-package-name
```

Replace your-api-key with your actual API key for the code review API, your-dir-path with the path to the directory containing the code to be reviewed, and your-package-name with the name of the Rust package on which to run the cargo commands.

Here are the available options:

-k, --api-key API_KEY: Set the API key for the GPT-based code review API.
-d, --dir-path DIR_PATH: Set the directory path for the code to be reviewed.
PACKAGE: The name of the Rust package to check, run clippy, and format.
You can display the script's usage information and options with -h or --help.

## Output
The script will output the results of each check (cargo check, cargo clippy, and cargo fmt), any found "TODO" or "FIXME" comments, and the response from the GPT-based code review API.

## Note
This script is intended for use in a Unix-like environment (like Linux or macOS). If you're using Windows, consider using the Windows Subsystem for Linux (WSL) or a similar tool.

It may not work properly in larger directories as the api is limited to 5000 characters per request. If you run into this issue, you can split the directory into multiple directories and run the script on each one.