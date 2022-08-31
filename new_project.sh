#!/bin/bash

# This script referenced code from following open source projects:
# https://github.com/ohmyzsh/ohmyzsh (Under MIT License)

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

print_info() {
  printf '%s[INFO] %s%s\n' "${FMT_BLUE}" "$*" "$FMT_RESET" >&2
}

print_success() {
  printf '%s[INFO] %s%s\n' "${FMT_GREEN}" "$*" "$FMT_RESET" >&2
}

print_warning() {
  printf '%s[WARN] %s%s\n' "${FMT_YELLOW}" "$*" "$FMT_RESET" >&2
}

print_error() {
  printf '%s[ERROR] %s%s\n' "${FMT_BOLD}${FMT_RED}" "$*" "$FMT_RESET" >&2
}

prompt_confirm () {
    while true; do
        read -p "${FMT_YELLOW}$1 (y/n):$FMT_RESET " choice
        case $choice in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) print_error "$choice is not a valid option";;
        esac
    done
}

setup_check() {
  FMT_RED=$(printf '\033[31m')
  FMT_GREEN=$(printf '\033[1;32m')
  FMT_YELLOW=$(printf '\033[1;33m')
  FMT_BLUE=$(printf '\033[1;34m')
  FMT_BOLD=$(printf '\033[1m')
  FMT_RESET=$(printf '\033[0m')

  if ! command_exists curl; then
    print_error "Please install curl before continuing. Follow setup guide for more info."
    exit 1
  elif ! command_exists sed; then
    print_error "Please install sed before continuing. Follow setup guide for more info."
    exit 1
  fi
}

setup_folder() {
  read -p "${FMT_YELLOW}Name your new project folder (e.g. Project1):$FMT_RESET " PROJECT_DIRNAME
  PARENT_DIR=$(pwd)
  PROJECT_DIR="${PARENT_DIR}/${PROJECT_DIRNAME}"

  print_success "Workspace path: $PROJECT_DIR"

  # Check if directory already exists
  if [ -d "$PROJECT_DIR" ]; then
    print_error "Directory already exists. Please try again."
    exit 1
  fi

  if ! prompt_confirm "Create your new project here?"; then
    print_error "Please run this script from the directory you want new project to be created."
    exit 1
  fi
}

get_scaffold() {
  curl -fsSL "https://github.com/CAENTainer/EECS498_008-Devcontainer/tarball/main" -o ${TMP_DIR}/scaffold.tar.gz
  if [ $? -ne 0 ]; then
    print_error "Failed to download starter files, please try again."
    exit 1
  fi
  tar -xzf ${TMP_DIR}/scaffold.tar.gz --strip-components=1 -C ${TMP_DIR}
}

open_project() {
  if command_exists devcontainer; then
    devcontainer open "${PROJECT_DIR}"
  elif command_exists code; then
    code "${PROJECT_DIR}"
  fi
}


main() {
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf -- "$TMP_DIR"' EXIT

  setup_check
  print_info "Welcome to EECS498-008 Dev Container Environment Setup Wizard"

  setup_folder

  print_info "Downloading starter files..."
  get_scaffold

  print_info "Moving files to workspace..."
  mv ${TMP_DIR}/Scaffold "${PROJECT_DIR}"

  print_success "Setup complete 🎉 Happy coding!"
  open_project
}

main "$@"
