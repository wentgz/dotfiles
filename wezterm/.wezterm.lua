local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Window
config.initial_cols = 120
config.initial_rows = 28

-- Fonts
config.font_size = 14
config.font = wezterm.font('JetBrains Mono', {
  weight = 'Regular',
  stretch = 'Normal',
  style = 'Normal',
})

-- Color scheme
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

local selected = wezterm.color.get_builtin_schemes()[selected_scheme]
assert(selected, 'Cannot find colorscheme: ' .. selected_scheme)

-- ANSI index reference (Lua table positions):
-- 1 black, 2 red, 3 green, 4 yellow,
-- 5 blue, 6 magenta, 7 cyan, 8 white
--
-- Original Zenbones palette reference:
-- ansi    = { '#f0edec', '#a8334c', '#4f6c31', '#944927',
--             '#286486', '#88507d', '#3b8992', '#2c363c' }
-- brights = { '#b5a7a0', '#94253e', '#3f5a22', '#803d1c',
--             '#1d5573', '#7b3b70', '#2b747c', '#4f5e68' }

if light_schemes[selected_scheme] then
  selected.ansi[3] = '#51af4e'
  selected.ansi[7] = '#0b8b99'
  selected.brights[5] = '#2177a5'
elseif dark_schemes[selected_scheme] then
  -- Custom dark-scheme colors go here.
end

local custom_scheme = selected_scheme .. '-custom'
config.color_schemes = { [custom_scheme] = selected }
config.color_scheme = custom_scheme

-- Renderer
config.front_end = 'WebGpu'

-- Mouse
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

-- Launch menu
config.launch_menu = {
  { label = 'PowerShell', args = { 'powershell' } },
  { label = 'Command Prompt', args = { 'cmd' } },
  { label = 'WSL Ubuntu 22.04', args = { 'wsl', '-d', 'ubuntu-22.04' } },
}

return config
