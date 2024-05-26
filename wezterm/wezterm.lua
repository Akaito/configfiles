-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.automatically_reload_config = true
--config.color_scheme = 'Monokai Pro (Gogh)'
config.color_scheme = 'Monokai Pro Ristretto (Gogh)'
config.enable_scroll_bar = true
config.initial_cols = 120
config.initial_rows = 60
config.window_padding = {
    left = 0,
    --right = '1cell',
    right = 0,
    top = 0,
    bottom = 0,
}

-- and finally, return the configuration to wezterm
return config

