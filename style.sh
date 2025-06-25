
NC="\033[0m"

color() {
  type="$1"
  color="$2"

  case "$color" in
    black)  code=0 ;;
    red)    code=1 ;;
    green)  code=2 ;;
    yellow) code=3 ;;
    blue)   code=4 ;;
    magenta)code=5 ;;
    cyan)   code=6 ;;
    white)  code=7 ;;
    *)      return ;;
  esac

  prefix=""
  [ "$type" = "fg" ] && prefix="3"
  [ "$type" = "bg" ] && prefix="4"

  echo "\033[${prefix}${code}m"
}

TW="$(($(tput cols) - 2 ))"
DASHED_LINE="$(printf -- "-%.0s" $(seq 1 $TW))"
LINKED_LINE="+$(printf -- "-%.0s" $(seq 1 $TW))+"


