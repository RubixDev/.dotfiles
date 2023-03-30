-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font 'JetBrainsMonoNL Nerd Font Mono'
-- config.color_scheme = 'OneDark (base16)'
config.hide_tab_bar_if_only_one_tab = true
config.font_size = 11
config.window_padding = {
    left = 3,
    right = 3,
    top = 0,
    bottom = 0,
}
config.window_background_opacity = 0.85
config.bold_brightens_ansi_colors = true

config.colors = {
  -- The default text color
  foreground = '#b2b2b2',
  -- The default background color
  background = '#241f31',

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = '#aaaaaa',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = 'black',
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = '#aaaaaa',

  -- the foreground color of selected text
  selection_fg = 'none',
  -- the background color of selected text
  selection_bg = 'rgba(50% 50% 60% 42%)',

  -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  scrollbar_thumb = '#222222',

  -- The color of the split lines between panes
  split = '#444444',

  ansi = {
    '#3f4451',
    '#e05561',
    '#8cc265',
    '#e1c652',
    '#4aa5f0',
    '#c162de',
    '#42b3c2',
    '#e6e6e6',
  },
  brights = {
    '#4f5666',
    '#ff616e',
    '#a5e075',
    '#f0c85d',
    '#4dc4ff',
    '#de73ff',
    '#4cd1e0',
    '#d7dae0',
  },

  -- Since: 20220319-142410-0fcdea07
  -- When the IME, a dead key or a leader key are being processed and are effectively
  -- holding input pending the result of input composition, change the cursor
  -- to this color to give a visual cue about the compose state.
  compose_cursor = 'orange',

  -- Colors for copy_mode and quick_select
  -- available since: 20220807-113146-c2fee766
  -- In copy_mode, the color of the active text is:
  -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
  -- 2. selection_* otherwise
  copy_mode_active_highlight_bg = { Color = '#000000' },
  -- use `AnsiColor` to specify one of the ansi color palette values
  -- (index 0-15) using one of the names "Black", "Maroon", "Green",
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
  copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
  copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },

  quick_select_label_bg = { Color = 'peru' },
  quick_select_label_fg = { Color = '#ffffff' },
  quick_select_match_bg = { AnsiColor = 'Navy' },
  quick_select_match_fg = { Color = '#ffffff' },
}

-- and finally, return the configuration to wezterm
return config
