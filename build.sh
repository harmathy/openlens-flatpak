#!/bin/bash

shopt -s -o errexit
shopt -s inherit_errexit
shopt -s -o nounset
shopt -s nullglob
shopt -s dotglob
shopt -s lastpipe

this="$(basename "$0")"
here="$(dirname "$(realpath "$0")")"

function usage_print_positional_parameter {
  local variable="$1"
  local description="$2"
  printf " %s\t%s\n" "$variable" "$description"
}

function usage_print_option_switch {
  local short="$1"
  local long="$2"
  local description="$3"
  printf " -%s | --%s\t%s\n" "$short" "$long" "$description"
}

function usage_print_optional_parameter {
  local short="$1"
  local long="$2"
  local variable="$3"
  local description="$4"
  printf " -%s | --%s %s\t%s\n" "$short" "$long" "$variable" "$description"
}

function usage {
  printf "%s [OPTIONS] [SOURCE]\n" "$this"
  printf "\n"
  printf "\nParameters:\n"
  usage_print_positional_parameter "SOURCE" "Source directory (default: \"$here\")"
  printf "\nOptions:\n"
  usage_print_option_switch "h" "help" "display this help message"
}

# process command line arguments
function process_args {
  local count=0
  while (("$#")); do
    case "$1" in
      "-h" | "--help")
        usage
        exit 0
        ;;
      *)
        case $count in
          0)
            source_directory="$1"
            ;;
          *)
            usage
            exit 1
            ;;
        esac
        ((count = count + 1))
        ;;
    esac
    shift
  done
}

function main {
  source_directory="$here"

  process_args "$@"

  if [ -z "$source_directory" ]; then
    source_directory="$(pwd)"
  fi

  (
    # shellcheck disable=SC2164
    cd "$source_directory"
    if [ -d build ]; then
      echo "Removing build directory!"
      rm -rf build
    fi
    flatpak-builder --keep-build-dirs build dev.k8slens.openlens.yml
    flatpak-builder --user --install --force-clean build dev.k8slens.openlens.yml
    flatpak run dev.k8slens.openlens
  )

}

main "$@"
