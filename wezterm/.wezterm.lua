-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- Initial geometry for new windows:
config.initial_cols = 120 
config.initial_rows = 28

-- Fonts
config.font_size = 14
config.font = wezterm.font('Consolas')

-- Dark themes
config.color_scheme = 'Kimber (base16)'
-- config.color_scheme = 'Teerb'

-- Light themes
-- config.color_scheme = 'Mar (Gogh)'
config.color_scheme = 'Lunaria Light (Gogh)'

config.front_end = "WebGpu"

config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local selection = window:get_selection_text_for_pane(pane)
  
            if selection and selection ~= '' then
                window:perform_action(act.CopyTo 'Clipboard', pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act.PasteFrom 'Clipboard', pane)
            end
        end),
    },
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = 'CTRL',
        action = act.IncreaseFontSize,
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = 'CTRL',
        action = act.DecreaseFontSize,
    },
}

config.launch_menu = {
    {
        label = 'PowerShell',
        args = { 'powershell' }
    },
    {
        label = 'Command Prompt',
        args = { 'cmd' }
    },
  }

-- Return the configuration to wezterm:
return config
