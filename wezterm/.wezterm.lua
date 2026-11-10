-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

config.initial_cols = 120 
config.initial_rows = 28

config.font_size = 14
config.font = wezterm.font('Jetbrains Mono')

config.color_scheme = 'Teerb'
-- config.color_scheme = 'seoulbones_light'
config.front_end = "WebGpu"   -- or "WebGpu"

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
		args = { 'cmd' },
    },
  }

return config
