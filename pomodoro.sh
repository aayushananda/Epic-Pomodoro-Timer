#!/bin/bash
# Epic Pomodoro Timer v3.2
# Features: Huge Block Timer, Non-blocking logic, Techy Art, Sound

CONFIG_FILE="$HOME/.pomodoro_config"
TMP_DIR="/tmp/pomodoro_art"
mkdir -p "$TMP_DIR"

WORK_TIME=25
SHORT_BREAK=5
LONG_BREAK=15
POMODOROS_UNTIL_LONG=4
SELECTED_ASCII_ART=""
ASCII_ART_SOURCE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Check dependencies
check_dependencies() {
  if ! command -v tte &>/dev/null; then
    echo -e "${RED}ERROR: terminaltexteffects not installed!${NC}"
    echo "Install: pip install terminaltexteffects"
    exit 1
  fi
  if ! command -v play &>/dev/null; then
    echo -e "${YELLOW}⚠ Audio disabled (install sox: sudo dnf install sox)${NC}"
    sleep 1
  fi
}

# Sound effects
play_sound() {
  if ! command -v play &>/dev/null; then return; fi
  case $1 in
  "start") play -n synth 0.5 sine 200-2000 fade 0 0.5 0 2>/dev/null & ;;
  "complete") play -n synth 0.3 sine 523 0.3 sine 659 0.3 sine 784 0.5 sine 1047 fade 0 0.5 0.1 2>/dev/null & ;;
  "tick") play -n synth 0.01 saw 1000 vol 0.1 2>/dev/null & ;;
  "warning") play -n synth 0.1 square 440 0.1 square 440 delay 0.15 2>/dev/null & ;;
  "click") play -n synth 0.05 sine 800 vol 0.5 2>/dev/null & ;;
  "count_beep") play -n synth 0.1 sine 800 vol 0.8 2>/dev/null & ;;
  esac
}

save_config() {
  cat >"$CONFIG_FILE" <<EOF
WORK_TIME=$WORK_TIME
SHORT_BREAK=$SHORT_BREAK
LONG_BREAK=$LONG_BREAK
POMODOROS_UNTIL_LONG=$POMODOROS_UNTIL_LONG
ASCII_ART_SOURCE="$ASCII_ART_SOURCE"
SELECTED_ASCII_ART="$SELECTED_ASCII_ART"
EOF
}

load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    return 0
  fi
  return 1
}

center_art() {
  local input_file=$1
  local output_file=$2
  local cols=$(tput cols)
  while IFS= read -r line; do
    line=$(echo "$line" | sed 's/[[:space:]]*$//')
    if [ -z "$line" ]; then echo "" >>"$output_file"; else
      local line_len=${#line}
      if [ $line_len -lt $cols ]; then
        local padding=$(((cols - line_len) / 2))
        printf "%${padding}s%s\n" "" "$line" >>"$output_file"
      else echo "$line" >>"$output_file"; fi
    fi
  done <"$input_file"
}

# --- HUGE ASCII DIGIT LOGIC ---
# Returns a specific line (1-5) of a specific digit (0-9 or :)
get_digit_line() {
  local digit=$1
  local line=$2

  case $digit in
  0)
    [ $line -eq 1 ] && echo " ██████╗ "
    [ $line -eq 2 ] && echo "██╔═══██╗"
    [ $line -eq 3 ] && echo "██║   ██║"
    [ $line -eq 4 ] && echo "██║   ██║"
    [ $line -eq 5 ] && echo "╚██████╔╝"
    ;;
  1)
    [ $line -eq 1 ] && echo "  ██╗ "
    [ $line -eq 2 ] && echo " ███║ "
    [ $line -eq 3 ] && echo " ╚██║ "
    [ $line -eq 4 ] && echo "  ██║ "
    [ $line -eq 5 ] && echo "  ╚═╝ "
    ;;
  2)
    [ $line -eq 1 ] && echo "██████╗ "
    [ $line -eq 2 ] && echo "╚════██╗"
    [ $line -eq 3 ] && echo " █████╔╝"
    [ $line -eq 4 ] && echo "██╔═══╝ "
    [ $line -eq 5 ] && echo "███████╗"
    ;;
  3)
    [ $line -eq 1 ] && echo "██████╗ "
    [ $line -eq 2 ] && echo "╚════██╗"
    [ $line -eq 3 ] && echo " █████╔╝"
    [ $line -eq 4 ] && echo " ╚═══██╗"
    [ $line -eq 5 ] && echo "██████╔╝"
    ;;
  4)
    [ $line -eq 1 ] && echo "██╗   ██╗"
    [ $line -eq 2 ] && echo "██║   ██║"
    [ $line -eq 3 ] && echo "████████║"
    [ $line -eq 4 ] && echo "╚═════██║"
    [ $line -eq 5 ] && echo "      ╚═╝"
    ;;
  5)
    [ $line -eq 1 ] && echo "███████╗"
    [ $line -eq 2 ] && echo "██╔════╝"
    [ $line -eq 3 ] && echo "███████╗"
    [ $line -eq 4 ] && echo "╚════██║"
    [ $line -eq 5 ] && echo "██████╔╝"
    ;;
  6)
    [ $line -eq 1 ] && echo "██████╗ "
    [ $line -eq 2 ] && echo "██╔════╝"
    [ $line -eq 3 ] && echo "███████╗"
    [ $line -eq 4 ] && echo "██╔══██║"
    [ $line -eq 5 ] && echo "╚██████╝"
    ;;
  7)
    [ $line -eq 1 ] && echo "███████╗"
    [ $line -eq 2 ] && echo "╚════██║"
    [ $line -eq 3 ] && echo "    ██╔╝"
    [ $line -eq 4 ] && echo "   ██╔╝ "
    [ $line -eq 5 ] && echo "   ╚═╝  "
    ;;
  8)
    [ $line -eq 1 ] && echo " ██████╗ "
    [ $line -eq 2 ] && echo "██╔═══██╗"
    [ $line -eq 3 ] && echo "╚██████╔╝"
    [ $line -eq 4 ] && echo "██╔═══██╗"
    [ $line -eq 5 ] && echo "╚██████╔╝"
    ;;
  9)
    [ $line -eq 1 ] && echo "██████╗ "
    [ $line -eq 2 ] && echo "██╔══██╗"
    [ $line -eq 3 ] && echo "╚██████║"
    [ $line -eq 4 ] && echo "     ██║"
    [ $line -eq 5 ] && echo "     ╚═╝"
    ;;
  :)
    [ $line -eq 1 ] && echo "   "
    [ $line -eq 2 ] && echo " █ "
    [ $line -eq 3 ] && echo "   "
    [ $line -eq 4 ] && echo " █ "
    [ $line -eq 5 ] && echo "   "
    ;;
  esac
}

# Renders the huge clock M M : S S
draw_big_clock() {
  local min_str=$(printf "%02d" $1)
  local sec_str=$(printf "%02d" $2)

  local m1=${min_str:0:1}
  local m2=${min_str:1:1}
  local s1=${sec_str:0:1}
  local s2=${sec_str:1:1}

  local cols=$(tput cols)
  # Total width of clock is roughly 40-45 chars. Calculate start padding.
  local pad_len=$(((cols - 46) / 2))
  local pad=$(printf "%${pad_len}s" "")

  # Construct the 5 lines of the clock
  for i in {1..5}; do
    local segment=""
    segment+="${GREEN}$(get_digit_line "$m1" $i)${NC}  "
    segment+="${GREEN}$(get_digit_line "$m2" $i)${NC} "
    segment+="${WHITE}$(get_digit_line ":" $i)${NC} "
    segment+="${CYAN}$(get_digit_line "$s1" $i)${NC}  "
    segment+="${CYAN}$(get_digit_line "$s2" $i)${NC}"

    echo -e "${pad}${segment}"
  done
}
# -----------------------------

use_builtin_ascii() {
  local output="${TMP_DIR}/builtin_pomodoro.txt"
  local raw_output="${TMP_DIR}/raw_builtin.txt"
  cat >"$raw_output" <<'EOF'
     __________________________________________
    /  SYSTEM STATUS: ONLINE                   \
    | [======================================] |
    |  __   __   __   __   __   __   __   __   |
    | [██] [██] [██] [██] [██] [██] [██] [██]  |
    |  __   __   __   __   __   __   __   __   |
    | [██] [██] [██] [██] [██] [██] [██] [██]  |
    |                                          |
    |  >> TACTICAL FOCUS MODULE ENGAGED <<     |
    \__________________________________________/
EOF
  >"$output"
  center_art "$raw_output" "$output"
  head -20 "$output" >"${output}.preview"
  SELECTED_ASCII_ART="${output}.preview"
  ASCII_ART_SOURCE="builtin"
}

run_huge_countdown() {
  clear
  tput civis
  # 3
  play_sound "count_beep"
  echo -e "\n\n\n\n"
  draw_big_clock 0 3
  sleep 1

  clear
  # 2
  play_sound "count_beep"
  echo -e "\n\n\n\n"
  draw_big_clock 0 2
  sleep 1

  clear
  # 1
  play_sound "count_beep"
  echo -e "\n\n\n\n"
  draw_big_clock 0 1
  sleep 1
  clear
}

show_ascii_art() {
  if [ -f "$SELECTED_ASCII_ART" ]; then
    local full_art="${SELECTED_ASCII_ART%.preview}"
    if [ -f "$full_art" ] && [ -s "$full_art" ]; then
      head -20 "$full_art" | tte thunderstorm --final-gradient-stops ffffff 0000ff
    else cat "$SELECTED_ASCII_ART" | tte thunderstorm --final-gradient-stops ffffff 0000ff; fi
  fi
}

show_ascii_art_static() {
  # Just print the file content cleanly for updates (no heavy tte delay)
  if [ -f "$SELECTED_ASCII_ART" ]; then
    echo -e "${BLUE}"
    cat "$SELECTED_ASCII_ART"
    echo -e "${NC}"
  fi
}

show_paused_screen() {
  clear
  echo ""
  cat <<"EOF" | tte print --final-gradient-stops ffff00 ff0000

    ██████╗  █████╗ ██╗   ██╗███████╗███████╗██████╗ 
    ██╔══██╗██╔══██╗██║   ██║██╔════╝██╔════╝██╔══██╗
    ██████╔╝███████║██║   ██║███████╗█████╗  ██║  ██║
    ██╔═══╝ ██╔══██║██║   ██║╚════██║██╔══╝  ██║  ██║
    ██║     ██║  ██║╚██████╔╝███████║███████╗██████╔╝
    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═════╝ 

EOF
  echo ""
  echo -e "${YELLOW}       ⏸  Timer paused. Press 'p' to resume...${NC}"
  echo ""
}

# --- SETUP FUNCTIONS (Same as before) ---
setup_ascii_art() {
  while true; do
    clear
    play_sound "click"
    echo -e "${BOLD}${MAGENTA}"
    cat <<"EOF" | tte print --final-gradient-stops ff00ff 00ffff

     █████╗ ███████╗ ██████╗██╗██╗
    ██╔══██╗██╔════╝██╔════╝██║██║
    ███████║███████╗██║     ██║██║
    ██╔══██║╚════██║██║     ██║██║
    ██║  ██║███████║╚██████╗██║██║
    ╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝╚═╝
             SETUP PHASE
EOF
    echo -e "${NC}\n"
    if [ -n "$SELECTED_ASCII_ART" ]; then echo -e "${GREEN}✓ Current selection: $ASCII_ART_SOURCE${NC}\n"; fi

    echo -e "${BOLD}${CYAN}Choose ASCII art source:${NC}"
    echo -e " ${BOLD}1)${NC} 🖼️  Use image from your computer"
    echo -e " ${BOLD}2)${NC} 🌐  Download from awesome-ascii-art"
    echo -e " ${BOLD}3)${NC} 📦  Use built-in Techy Art"
    echo ""
    if [ -n "$SELECTED_ASCII_ART" ]; then
      echo -e " ${BOLD}4)${NC} 👁️  Preview current selection"
      echo -e " ${BOLD}5)${NC} ✅  Continue to timer setup"
    fi
    echo -e " ${BOLD}0)${NC} ❌  Exit\n"
    echo -ne "${GREEN}Select option:${NC} "
    read choice
    case $choice in
    3)
      use_builtin_ascii
      echo -e "${GREEN}✓ Built-in ASCII art selected!${NC}"
      sleep 1
      ;;
    5) if [ -n "$SELECTED_ASCII_ART" ]; then return 0; else
      echo -e "${YELLOW}⚠ Please select ASCII art first!${NC}"
      sleep 2
    fi ;;
    0)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo -e "${YELLOW}Option not implemented in this snippet${NC}"
      use_builtin_ascii
      return 0
      ;;
    esac
  done
}

setup_timer() {
  while true; do
    clear
    play_sound "click"
    echo -e "${BOLD}${BLUE}"
    cat <<"EOF" | tte print --final-gradient-stops 0000ff ffffff

    ████████╗██╗███╗   ███╗███████╗██████╗ 
    ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗
       ██║   ██║██╔████╔██║█████╗  ██████╔╝
       ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗
       ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║
       ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
             CONFIGURATION
EOF
    echo -e "${NC}\n"
    echo -e " 📚 ${BOLD}Work Session:${NC} ${GREEN}${WORK_TIME}${NC}m | ☕ ${BOLD}Short:${NC} ${YELLOW}${SHORT_BREAK}${NC}m | 🌴 ${BOLD}Long:${NC} ${MAGENTA}${LONG_BREAK}${NC}m\n"
    echo -e "${BOLD}${CYAN}Options:${NC}"
    echo -e " ${BOLD}1)${NC} ⚙️  Change work time"
    echo -e " ${BOLD}2)${NC} ⚙️  Change short break"
    echo -e " ${BOLD}3)${NC} ⚙️  Change long break"
    echo -e " ${BOLD}5)${NC} 💾  Save configuration"
    echo -e " ${BOLD}8)${NC} 🚀  START TIMER!"
    echo -e " ${BOLD}0)${NC} ❌  Exit\n"
    echo -ne "${GREEN}Select option:${NC} "
    read choice
    case $choice in
    1) read -p "Enter work time: " WORK_TIME ;;
    2) read -p "Enter short break: " SHORT_BREAK ;;
    3) read -p "Enter long break: " LONG_BREAK ;;
    5)
      save_config
      echo -e "${GREEN}✓ Saved!${NC}"
      sleep 1
      ;;
    8) return 0 ;;
    0) exit 0 ;;
    esac
  done
}
# -----------------------------

countdown() {
  local minutes=$1
  local label=$2
  local seconds=$((minutes * 60))
  local paused=false

  clear
  play_sound "start"

  # 1. Show art ONCE with effect at start
  show_ascii_art

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo -e "${BOLD}${CYAN}   $label${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  local term_height=$(tput lines)
  local controls_row=$((term_height - 2))
  local timer_row=22 # Approximate position below art

  # Initial Draw
  tput cup $timer_row 0
  draw_big_clock $minutes 0

  tput cup $controls_row 0
  echo -e "${CYAN} Controls: ${YELLOW}[P]${NC}ause  ${YELLOW}[S]${NC}kip  ${YELLOW}[Q]${NC}uit${NC}"

  while [ $seconds -gt 0 ]; do
    # Non-blocking input
    if read -t 0.1 -n 1 key 2>/dev/null; then
      case $key in
      p | P)
        if [ "$paused" = false ]; then
          paused=true
          play_sound "click"
          show_paused_screen
        else
          paused=false
          play_sound "click"
          clear
          # On resume, show static art to avoid re-triggering slow effect
          show_ascii_art_static
          echo ""
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo -e "${BOLD}${CYAN}   $label${NC}"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
        ;;
      s | S)
        play_sound "click"
        seconds=0
        break
        ;;
      q | Q)
        cleanup
        exit 0
        ;;
      esac
    fi

    if [ "$paused" = true ]; then continue; fi

    # Draw HUGE Timer
    # We assume the Art takes up the top ~20 lines. We position cursor below it.
    tput cup $timer_row 0
    draw_big_clock $((seconds / 60)) $((seconds % 60))

    # Redraw controls at bottom
    tput cup $controls_row 0
    echo -e "${CYAN} Controls: ${YELLOW}[P]${NC}ause  ${YELLOW}[S]${NC}kip  ${YELLOW}[Q]${NC}uit${NC}"

    [ $((seconds % 60)) -eq 0 ] && play_sound "tick"

    # We manually sleep remainder of second since read took 0.1s
    sleep 0.9
    ((seconds--))
  done

  clear
  play_sound "complete"
  echo "DONE"
  sleep 2
}

main() {
  check_dependencies
  if load_config && [ -f "$SELECTED_ASCII_ART" ]; then
    clear
    echo -e "${YELLOW}Use saved config? [y/n]:${NC} "
    read -n 1 -r use_saved
    echo ""
    if [[ ! $use_saved =~ ^[Yy]$ ]]; then
      setup_ascii_art
      setup_timer
    fi
  else
    setup_ascii_art
    setup_timer
  fi

  save_config
  run_huge_countdown

  pomodoro_count=0
  while true; do
    ((pomodoro_count++))
    countdown $WORK_TIME "Work Session #${pomodoro_count}"
    if [ $((pomodoro_count % POMODOROS_UNTIL_LONG)) -eq 0 ]; then countdown $LONG_BREAK "Long Break"; else countdown $SHORT_BREAK "Short Break"; fi
    clear
    echo -e "${GREEN}Next? [y/n]:${NC} "
    read -n 1 -r choice
    [[ ! $choice =~ ^[Yy]$ ]] && exit 0
  done
}

cleanup() { tput cnorm; }
trap cleanup EXIT
tput civis
main
