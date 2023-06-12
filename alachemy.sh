#!/usr/bin/env sh

set -e

UINT="^(\d+)$"
BOOLEAN="^(true|false)$"
STRING="[a-zA-Z\s]"
FLOAT="^\d+(\.\d)?$"
FLOAT_0_1="^(0(\.\d+)?|1(\.0+)?)$"
HEX_STRING="^['\"](#|0x)[0-9a-fA-F]{6}['\"]$"
ESPACE_CHARS="^['\"][,\\?\`|:\"'\s()\[\]{}<>\tt]+['\"]$"

err() {
  printf >&2 "error: %s\n" "$@"
  exit 1
}

if ! command -v alacritty >/dev/null; then
  err "missing alacritty"
fi

if ! command -v yq >/dev/null; then
  err "missing yq"
fi

enum() {
  enum_str="$1"
  shift
  for arg; do
    enum_str="${enum_str}|${arg}"
  done

  printf "^(%s)$" "${enum_str}"
}

alacritty_config_schema="$(cat <<EOF
env:
  TERM: $STRING

window:
  dimensions:
    columns: $UINT
    lines: $UINT
  position:
    x: $UINT
    y: $UINT
  padding:
    x: $UINT
    y: $UINT
  dynamic_padding: $BOOLEAN
  decorations: $(enum full none transparent buttonless)
  opacity: $FLOAT_0_1
  startup_mode: $(enum Windowed Maximized Fullscreen SimpleFullscreen)
  title: $STRING
  dynamic_title: $BOOLEAN
  class:
    instance: $STRING
    general: $STRING
    decorations_theme_variant: $(enum Dark Light None)
  resize_increments: $BOOLEAN
  option_as_alt: $(enum OnlyLeft OnlyRight Both None)

scrolling:
  history: $UINT
  multiplier: $UINT

font:
  normal:
    family: $STRING
    style: $STRING
  bold:
    family: $STRING
    style: $STRING
  italic:
    family: $STRING
    style: $STRING
  bold_italic:
    family: $STRING
    style: $STRING
  size: $FLOAT
  offset:
    x: $UINT
    y: $UINT
  glyph_offset:
    x: $UINT
    y: $UINT
  builtin_box_drawing: $BOOLEAN

draw_bold_text_with_bright_colors: $BOOLEAN

colors:
  primary:
    background: $HEX_STRING
    foreground: $HEX_STRING
    dim_foreground: $HEX_STRING
    bright_foreground: $HEX_STRING
  cursor:
    text: $(enum CellBackground "${HEX_STRING}")
    cursor: $(enum CellForeground "${HEX_STRING}")
  vi_mod_cursor:
    text: $(enum CellBackground "${HEX_STRING}")
    cursor: $(enum CellForeground "${HEX_STRING}")
  search:
    matches:
      foreground: $(enum CellForeground "${HEX_STRING}")
      background: $(enum CellBackground "${HEX_STRING}")
    focused_match:
      foreground: $(enum CellForeground "${HEX_STRING}")
      background: $(enum CellBackground "${HEX_STRING}")
  hints:
    start:
      foreground: $(enum CellForeground "${HEX_STRING}")
      background: $(enum CellBackground "${HEX_STRING}")
    end:
      foreground: $(enum CellForeground "${HEX_STRING}")
      background: $(enum CellBackground "${HEX_STRING}")
  line_indicator:
    foreground: $(enum None "${HEX_STRING}")
    background: $(enum None "${HEX_STRING}")
  footer_bar:
    foreground: $HEX_STRING
    background: $HEX_STRING
  selection:
    text: $(enum CellBackground "${HEX_STRING}")
    background: $(enum CellForeground "${HEX_STRING}")
  normal:
    black:   $HEX_STRING
    red:     $HEX_STRING
    green:   $HEX_STRING
    yellow:  $HEX_STRING
    blue:    $HEX_STRING
    magenta: $HEX_STRING
    cyan:    $HEX_STRING
    white:   $HEX_STRING
  bright:
    black:   $HEX_STRING
    red:     $HEX_STRING
    green:   $HEX_STRING
    yellow:  $HEX_STRING
    blue:    $HEX_STRING
    magenta: $HEX_STRING
    cyan:    $HEX_STRING
    white:   $HEX_STRING
  dim:
    black:   $HEX_STRING
    red:     $HEX_STRING
    green:   $HEX_STRING
    yellow:  $HEX_STRING
    blue:    $HEX_STRING
    magenta: $HEX_STRING
    cyan:    $HEX_STRING
    white:   $HEX_STRING
  # TBD
  #indexed_colors: []
  transparent_background_colors: $BOOLEAN

bell:
  animation: $(enum Ease EaseOut EaseOutSine EaseOutQuad EaseOutCubic EaseOutQuart EaseOutQuint EaseOutExpo EaseOutCirc Linear)
  duration: $UINT
  color: $HEX_STRING
  # TBD
  #command: None

selection:
  semantic_escape_chars: $ESPACE_CHARS
  save_to_clipboard: $BOOLEAN

cursor:
  style:
    shape: $(enum Block Underline Beam)
    blinking: $(enum Never Off On Always)
  # TBD
  # vi_mode_style:
  blink_interval: $UINT
  blink_timeout: $UINT
  unfocused_hollow: $BOOLEAN
  thickness: $FLOAT_0_1

live_config_reload: $BOOLEAN

shell:
  program: $STRING
  # TBD
  # args:

working_directory: $(enum None "${STRING}")

ipc_socket: $BOOLEAN

mouse:
  # TBD
  # double_click:
  # triple_click:
  hide_when_typing: $BOOLEAN

hints:
  alphabet: $STRING
  # TBD
  # enabled:
  # - regex: "(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)\
  #           [^\u0000-\u001F\u007F-\u009F<>\"\\s{-}\\^??\`]+"
  #   hyperlinks: true
  #   command: xdg-open
  #   post_processing: true
  #   mouse:
  #     enabled: true
  #     mods: None
  #   binding:
  #     key: U
  #     mods: Control|Shift

# TBD
# mouse_bindings:
#  - { mouse: Right,                 action: ExpandSelection }
#  - { mouse: Right,  mods: Control, action: ExpandSelection }
#  - { mouse: Middle, mode: ~Vi,     action: PasteSelection  }

# TBD
# key_bindings:

debug:
  render_timer: $BOOLEAN
  persistent_logging: $BOOLEAN
  log_level: $(enum Off Error Warn Info Debug Trace)
  renderer: $(enum glsl3 gles2 gles2_pure None)
  print_events: $BOOLEAN
  highlight_damage: $BOOLEAN
EOF
  )"

validate() {
  if printf "%s" "$1" | grep -qE "$2"; then
    return 0
  fi
  return 1
}

help() {
  cat <<EOF
alachemy
A simple config manager for Alacritty

USAGE

	alachemy <key> <value> [-h | --help]

OPTIONS
	-h --help	Show help

EXAMPLES
	An example of setting alacritty window opacity to a value of 0.85 
	alachemy window.opacity 0.85
EOF
  exit 2
}

alachemy() {
  [ "$#" -eq 0 ] && help

  for arg; do
    case "$arg" in
     -h | --help) help ;;
    esac
  done

  [ -z "$2" ] && err "expected value as the second argument, but got none"

  key="$1"
  value="$2"

  comp_a="${key%.*}"
  comp_b="${key##*.}"

  has_key="$(printf "%s" "${alacritty_config_schema}" | yq ".${comp_a} | has(\"${comp_b}\")")"

  [ "${has_key}" = false ] && {
    err "\"${key}\" does not exist in config schema"
  }

  value_type="$(printf "%s" "${alacritty_config_schema}" | yq ".${key}")"

  if validate "${value}" "${value_type}"; then
    yq -i ".${key}=${value}" "${HOME}/.alacritty.yml"
    exit 0
  fi

  printf "error: %s\n" "value \"$value\" does not match expected schema"
  printf "%s" "${alacritty_config_schema}" | grep "${comp_b}";
  exit 1
}

alachemy "$@"
