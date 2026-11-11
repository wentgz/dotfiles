-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- Initial geometry for new windows:
config.initial_cols = 120 
config.initial_rows = 28

config.line_height = 1.2

-- Fonts
config.font_size = 12
config.font = wezterm.font('Consolas')

local selected_scheme = 'zenbones'

local light_schemes = {
  ['Mar (Gogh)'] = true,
  ['iceberg-light'] = true,
  ['Lunaria Light (Gogh)'] = true,
  ['Harmonic16 Light (base16)'] = true,
  ['zenbones'] = true,
}

local dark_schemes = {
  ['Kimber (base16)'] = true,
  ['Teerb'] = true,
}

local schemes = wezterm.color.get_builtin_schemes()
local selected = schemes[selected_scheme]

if not selected then
  error('Cannot find colorscheme: ' .. selected_scheme)
end

if light_schemes[selected_scheme] then
  selected.ansi[3] = '#34aa34'
  selected.brights[3] = '#17b617'
elseif dark_schemes[selected_scheme] then
    -- custom dark scheme color
end

local custom_name = selected_scheme .. '-custom'
config.color_schemes = {
  [custom_name] = selected,
}
config.color_scheme = custom_name

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
