--[[============================================================================
Duplex.Application.Effect
============================================================================]]--

--[[--

The Effect application enables control of DSP chain parameters.

#

[View the README.md](https://github.com/renoise/xrnx/blob/master/Tools/com.renoise.Duplex.xrnx/Docs/Applications/Effect.md) (github)

--]]


--==============================================================================

-- default precision we're using to compare floating point values in Effect

local FLOAT_COMPARE_QUANTUM = 1000

-- option constants

local ALL_PARAMETERS = 1
local AUTOMATED_PARAMETERS = 2
local MIXER_PARAMETERS = 3
local CUSTOM_PARAMETERS = 4
local RECORD_NONE = 1
local RECORD_TOUCH = 2
--local RECORD_LATCH = 3

-- Custom parameter mapping:
-- { "name", { "params" }, { "customparamnames" }}
-- Use for _,parameter in ipairs(renoise.song().selected_sample_device.parameters) do print(parameter.name) end to retrieve parameters
-- print(renoise.song().selected_sample_device.name) for device name
-- Choose random parameter that ideally stays off for a dummy param, use "-" for custom name

local custom =
   {
      {
         "VST3: Tokyo Dawn Labs: TDR Molot GE",
         {
            "Input", "Thresh.", "Ratio", "Attack",
            "Release", "Att.Mod", "DryMix", "Makeup",
         },
         {
            "Input", "Thrs.", "Ratio", "Atk",
            "Rel", "A-S", "Dry/Wet", "Make up",
         }
      },
   },



--==============================================================================

class 'InstrumentModulation' (Automateable)

InstrumentModulation.default_options = {
  include_parameters = {
    label = "Param. subset",
    description = "Select which parameter set you want to control.",
    items = {
      "All parameters (device)",
      "Automated parameters (track)",
      "Mixer parameters (track)",
      "Custom parameters (device)",
    },
    value = 1,
    on_change = function(inst)
      local mode = (inst.options.include_parameters.value) 
      if ((mode == ALL_PARAMETERS) or (mode == CUSTOM_PARAMETERS)) then
        inst._update_requested = true
      else
        inst._track_update_requested = true
      end
    end,
  },

}

-- apply control-maps groups 
InstrumentModulation.available_mappings = {

  parameters = {
    description = "InstrumentModulation: Parameter value",
    component = UISlider,
    distributable = true,
    greedy = true,
    -- grid support 
    orientation = ORIENTATION.HORIZONTAL,
    flipped = true,
    toggleable = true,
    index = 1,
  },
  param_next = {
    description = "InstrumentModulation: Next Parameter page",
    component = UIButton,
    distributable = true,
  },
  param_prev = {
    description = "InstrumentModulation: Previous Parameter page",
    component = UIButton,
    distributable = true,
  },
  device = {
    description = "InstrumentModulation: Select among devices via buttons",
    component = {{UIButton}},
    distributable = true,
    greedy = true,
  },
  device_select = {
    description = "InstrumentModulation: Select device via knob/slider",
    component = UISlider,
    orientation = ORIENTATION.HORIZONTAL,
  },
  device_next = {
    description = "InstrumentModulation: Select next device",
    component = UIButton,
  },
  device_prev = {
    description = "InstrumentModulation: Select previous device",
    component = UIButton,
  },
  preset_next = {
    description = "InstrumentModulation: Select next device preset",
    component = UIButton,
  },
  preset_prev = {
    description = "InstrumentModulation: Select previous device preset",
    component = UIButton,
  },
  device_name = {
    description = "InstrumentModulation: Display device name",
    component = UILabel,
  },
  preset_name = {
    description = "InstrumentModulation: Display preset name",
    component = UILabel,
  },
  param_names = {
    description = "InstrumentModulation: Display parameter name",
    distributable = true,
    greedy = true,
  },
  param_values = {
    description = "InstrumentModulation: Display parameter value",
    distrubutable = true,
    greedy = true,
  },
  param_active = {
    -- used with the Launchcontrol to illustrate which
    -- encoders are actively controlling an effect-parameter
    description = "(UILed...) Display active parameter",
    greedy = true,
  },
  macros = {
    description = "InstrumentModulation: Macro value",
    component = UISlider,
    distributable = true,
    greedy = true,
    -- grid support 
    orientation = ORIENTATION.HORIZONTAL,
    flipped = true,
    toggleable = true,
    index = 1,
  },
  macro_names = {
    description = "InstrumentModulation: Display Macro name",
    distributable = true,
    greedy = true,
  },
  macro_values = {
    description = "InstrumentModulation: Display Macro value",
    distrubutable = true,
    greedy = true,
  },
  ext_editor = {
    -- Toggles device external gui, if any
    description = "InstrumentModulation: Display external editor",
    component = UIButton,
  },
  volume_input = {
    description = "InstrumentModulation: Set Volume Input",
    component = UISlider,
  },
  volume_value = {
    description = "InstrumentModulation: Display Volume Input value",
  },
  panning_input = {
    description = "InstrumentModulation: Set Panning Input",
    component = UISlider,
  },
  panning_value = {
    description = "InstrumentModulation: Display Panning Input value",
  },
  pitch_input = {
    description = "InstrumentModulation: Set Pitch Input",
    component = UISlider,
  },
  pitch_value = {
    description = "InstrumentModulation: Display Pitch Input value",
  },
  pitch_range = {
    description = "InstrumentModulation: Set Pitch range",
    component = UISlider,
  },
  pitch_range_value = {
    description = "InstrumentModulation: Display Pitch Range value",
  },
  filter_type = {
    description = "InstrumentModulation: Set Filter type",
    component = UISlider,
  },
  filter_type_value = {
    description = "InstrumentModulation: Display Filter Type",
  },
  cutoff_input = {
    description = "InstrumentModulation: Set Cutoff Input",
    component = UISlider,
  },
  cutoff_value = {
    description = "InstrumentModulation: Display Cutoff Input value",
  },
  resonance_input = {
    description = "InstrumentModulation: Set Resonance Input",
    component = UISlider,
  },
  resonance_value = {
    description = "InstrumentModulation: Display Resonance Input value",
  },
  drive_input = {
    description = "InstrumentModulation: Set Drive Input",
    component = UISlider,
  },
  drive_value = {
    description = "InstrumentModulation: Display drive Input value",
  },

  fine = {
    description = "InstrumentModulation: Fine-control toggle"
  },


}

-- define default palette
InstrumentModulation.default_palette = {
  -- parameter sliders
  background = {        color={0x00,0x00,0x00},   text="·",   val=false },
  slider_background = { color={0x00,0x40,0x00},   text="·",   val=false },
  slider_tip = {        color={0XFF,0XFF,0XFF},   text="·",   val=true },
  slider_track = {      color={0XFF,0XFF,0XFF},   text="·",   val=true },
  -- device-buttons
  device_nav_on = {     color={0XFF,0XFF,0XFF},   text="■",   val=true },
  device_nav_off = {    color={0x00,0x00,0x00},   text="·",   val=false },
  prev_device_on = {    color = {0xFF,0xFF,0xFF}, text = "◄", val=true },
  prev_device_off = {   color = {0x00,0x00,0x00}, text = "◄", val=false },
  next_device_on = {    color = {0xFF,0xFF,0xFF}, text = "►", val=true },
  next_device_off = {   color = {0x00,0x00,0x00}, text = "►", val=false },
  -- preset buttons
  prev_preset_on = {    color = {0xFF,0xFF,0xFF}, text = "◄", val=true },
  prev_preset_off = {   color = {0x00,0x00,0x00}, text = "◄", val=false },
  next_preset_on = {    color = {0xFF,0xFF,0xFF}, text = "►", val=true },
  next_preset_off = {   color = {0x00,0x00,0x00}, text = "►", val=false },
  -- parameter pages
  prev_param_on = {     color = {0xFF,0xFF,0xFF}, text = "◄", val=true },
  prev_param_off = {    color = {0x00,0x00,0x00}, text = "◄", val=false },
  next_param_on = {     color = {0xFF,0xFF,0xFF}, text = "►", val=true },
  next_param_off = {    color = {0x00,0x00,0x00}, text = "►", val=false },
  -- parameter active 
  parameter_on = {      color = {0xFF,0xFF,0xFF}, val=true },
  parameter_off = {     color = {0x00,0x00,0x00}, val=false },

  -- external device editor
  ext_editor_on = {      color = {0xFF,0x00,0x00}, text = "Ext.", val=true },
  ext_editor_off = {     color = {0x00,0x00,0x00}, text = "Ext.", val=false },
  ext_editor_nil = {     color = {0x00,0x00,0x00}, text = "", val=false },
  -- Fine-control buttons
  fine_on           = { color={0xff,0xff,0xff}, val = true, text = "Fine",},
  fine_off          = { color={0x00,0x00,0x00}, val = false,text = "Fine", },

}

--------------------------------------------------------------------------------
--  merge superclass options, mappings & palette --

for k,v in pairs(Automateable.default_options) do
  InstrumentModulation.default_options[k] = v
end
for k,v in pairs(Automateable.available_mappings) do
  InstrumentModulation.available_mappings[k] = v
end
for k,v in pairs(Automateable.default_palette) do
  InstrumentModulation.default_palette[k] = v
end

--------------------------------------------------------------------------------

--- Constructor method
-- @param (VarArg) 
-- @see Application

function InstrumentModulation:__init(...)
  TRACE("InstrumentModulation:__init", ...)
  -- the controls
  self._parameter_sliders = nil
  self._device_navigators = nil
  self._device_select = nil
  self._device_next = nil
  self._device_prev = nil
  self._preset_next = nil
  self._preset_prev = nil
  self._device_name = nil
  self._preset_name = nil
  self._param_names = nil
  self._param_next = nil
  self._param_prev = nil
  self._ext_editor = nil
  self._macro_names = nil

  self._volume_input = nil
  self._panning_input = nil
  self._pitch_input = nil
  self._filter_type = nil
  self._filter_type_value = nil
  self._cutoff_input = nil
  self._resonance_input = nil
  self._drive_input = nil

  --- (int) the number of controls assigned as sliders
  self._slider_group_size = nil

  --- (int or nil) the maximum size of a slider
  self._slider_max_size = nil

  --- (bool) true if sliders are in grid mode
  self._slider_grid_mode = false

  --- (table) indexed table, each entry contains:
  --    device_index (int)
  --    ref (renoise.DeviceParameter)
  self._parameter_set = table.create()

  --- (int) how many devices are included in our parameter set?
  self._num_devices = 1

  -- Fine accel multiplier
  self._fine = nil
  self._fine_accel = 1

  -- Current sample modulation device
  self._device_idx = 1

  --- (int) offset of the whole parameter mapping, controlled by the page navigator
  self._parameter_offset = 0
  
  --- list of parameters we are currently listening to
  self._parameter_observables = table.create()
  self._macro_observables = table.create()
  self._device_observables = table.create()
  self._preset_observables = table.create()
  self._mixer_observables = table.create()
  self._mod_input_observables = table.create()

  --- (table) references to various UI controls 
  self._param_names  = {}
  self._param_values = {}
  self._param_active = {}
  self._macro_names = {}

  Automateable.__init(self,...)
  --self:list_mappings_and_options(InstrumentModulation)

end

--------------------------------------------------------------------------------

--- parameter value changed from Renoise
-- @param control_index (int) 
-- @param value (number) _mostly_ between 0 and 1
-- @param skip_event (bool) do not trigger event

function InstrumentModulation:set_parameter(control_index, value, skip_event)
  TRACE("InstrumentModulation:set_parameter", control_index, value, skip_event)

  if not self.active then
    return
  end

  --- value needs to be positive (this is not true with the multitap-
  -- delay, in which the "panic" button will output a negative value)
  if (value<0) then
    value = 0
  end

  self._parameter_sliders[control_index]:set_value(value, skip_event)

end

--------------------------------------------------------------------------------

--- macro value changed from Renoise
-- @param control_index (int) 
-- @param value (number) _mostly_ between 0 and 1
-- @param skip_event (bool) do not trigger event

function InstrumentModulation:set_macro(control_index, value, skip_event)
  TRACE("InstrumentModulation:set_macro", control_index, value, skip_event)

  if not self.active then
    return
  end

  --- value needs to be positive (this is not true with the multitap-
  -- delay, in which the "panic" button will output a negative value)
  if (value<0) then
    value = 0
  end

  self._macro_sliders[control_index]:set_value(value, skip_event)

end

--------------------------------------------------------------------------------

--- update: set all controls to current values from renoise

function InstrumentModulation:update()  
  TRACE("InstrumentModulation:update()")

  local skip_event = true

  local parameters = self._parameter_set

  local cm = self.display.device.control_map
  local inst_idx = rns.selected_instrument_index
  local modset_idx = rns.selected_sample_modulation_set_index
  local device = rns.selected_sample_modulation_set.devices[self._device_idx]

  -- update prev/next device buttons
  self:_update_prev_next_device_buttons(self._device_idx)

  -- update external editor button
  self:_update_ext_editor_button(self._device_idx)
  
  -- update device label
  if self._device_name and rns.selected_sample_modulation_set and rns.selected_sample_modulation_set.devices[self._device_idx] then
    self._device_name:set_text(device.display_name)
  else
    self._device_name:set_text("-")
  end
  
  if (self.mappings.parameters.group_name) then
    for control_index = 1,self._slider_group_size do

      local param_value = nil
      local parameter_index = self._parameter_offset + control_index
      local parameter = self:_get_parameter_by_index(parameter_index)
      -- set default values  
      if (parameter_index <= #parameters) then
        
        -- update component states from the parameter, 
        -- hackily check for valid ranges, in order to suppress updates of
        -- temporarily wrong values that we get from Renoise (-1 for the meta 
        -- device effect/device choosers)    
        if (parameter.value >= parameter.value_min and 
            parameter.value <= parameter.value_max) 
        then
          -- normalize to the controls [0-1] range
          local normalized_value = self:_parameter_value_to_normalized_value(
            parameter, parameter.value) 
          self:set_parameter(control_index, normalized_value, skip_event)
        else
          self:set_parameter(control_index, 0, skip_event)
        end

        param_value = parameter.value_string

        if self._param_active[control_index] then
          self._param_active[control_index]:set(self.palette.parameter_on)
          --print("set to on",self._param_active[control_index],control_index)
        end

      else
        -- deactivate, reset controls which have no parameter assigned
        self:set_parameter(control_index, 0, skip_event)
        param_value = ""

        if self._param_values[control_index] then
          self._param_values[control_index]:set_text(param_value)
        end

        if self._param_active[control_index] then
          self._param_active[control_index]:set(self.palette.parameter_off)
          --print("set to off",self._param_active[control_index],control_index)
        end

      end
    end

  end
  local macro_map = self.mappings.macros
  local macros = cm:get_params(macro_map.group_name,macro_map.index)
  if (self.mappings.macros.group_name) then
    for control_index = 1,#macros do
      local macro_value = nil
      local macro = rns.selected_instrument.macros[control_index]

      if (macro) then
        if (macro.value >= 0 and 
            macro.value <= 1) 
        then
          local value = macro.value
          self:set_macro(control_index, value, skip_event)
        else
          self:set_macro(control_index, 0, skip_event)
        end

        macro_value = macro.value_string
        
      else
        self:set_macro(control_index, 0, skip_event)
        macro_value = ""
      end

      if self._macro_values[control_index] then
        self._macro_values[control_index]:set_text(macro_value)
      end

      --print("*** param_value",param_value)

    end
  end
  
  -- update button-based device selectors
  if (self._device_navigators) then

    if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
      -- set the device navigator to the current fx
      for control_index = 1,#self._device_navigators do
        if (device_idx==control_index) then
          self._device_navigators[control_index]:set(self.palette.device_nav_on)
        else
          self._device_navigators[control_index]:set(self.palette.device_nav_off)
        end

        -- update tooltip
        local device = rns.instruments[inst_idx]:sample_device_chain(track_idx).devices[control_index]   
        self._device_navigators[control_index].tooltip = (device) and 
          string.format("Set focus to %s",device.name) or
          "InstrumentModulation device N/A"
      end
    else
      -- parameter subsets require a different approach
      local count = 0
      for control_idx = 1,#self._device_navigators do
        local is_current = false
        local device = nil
        -- go through the parameter set, each entry with
        -- a higher device_index will be added 
        for _,prm in ipairs(self._parameter_set) do
          if (prm.device_index>count) then
            is_current = (prm.device_index==rns.selected_sample_device_index) 
            device = rns.instruments[inst_idx]:sample_device_chain(track_idx).devices[prm.device_index]   
            count = prm.device_index
            break
          end
        end
        if is_current then
          self._device_navigators[control_idx]:set(self.palette.device_nav_on)
        else
          self._device_navigators[control_idx]:set(self.palette.device_nav_off)
        end
        -- update tooltip
        self._device_navigators[control_idx].tooltip = (device) and 
          string.format("Set focus to %s",device.name) or
          "InstrumentModulation device N/A"
      end
    end

    self.display:apply_tooltips(self.mappings.device.group_name)

  end

  local volume_input = rns.selected_sample_modulation_set.volume_input
  if (volume_input and self.mappings.volume_input.group_name) then
    if (volume_input.value >= volume_input.value_min and
        volume_input.value <= volume_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        volume_input, volume_input.value)
      self._volume_input:set_value(normalized_value, skip_event)
    else
      self._volume_input:set_value(0, skip_event)
    end
    if self._volume_value then
      self._volume_value:set_text(volume_input.value_string)
    end
  end
  
  local panning_input = rns.selected_sample_modulation_set.panning_input
  if (panning_input and self.mappings.panning_input.group_name) then
    if (panning_input.value >= panning_input.value_min and
        panning_input.value <= panning_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        panning_input, panning_input.value)
      self._panning_input:set_value(normalized_value, skip_event)
    else
      self._panning_input:set_value(0, skip_event)
    end
    if self._panning_value then
      self._panning_value:set_text(panning_input.value_string)
    end
  end
  
  local pitch_input = rns.selected_sample_modulation_set.pitch_input
  if (pitch_input and self.mappings.pitch_input.group_name) then
    if (pitch_input.value >= pitch_input.value_min and
        pitch_input.value <= pitch_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        pitch_input, pitch_input.value)
      self._pitch_input:set_value(normalized_value, skip_event)
    else
      self._pitch_input:set_value(0, skip_event)
    end
    if self._pitch_value then
      self._pitch_value:set_text(pitch_input.value_string)
    end
  end
  
  local pitch_range = rns.selected_sample_modulation_set.pitch_range
  if (pitch_range and self.mappings.pitch_range.group_name) then
    if (pitch_range >= 1 and
        pitch_range <= 96)
    then
      --normalize to co_valuentol range [0-1]
      local normalized_value = self:_pitch_range_to_normalized_value(
        pitch_range)
      self._pitch_range:set_value(normalized_value, skip_event)
    else
      self._pitch_range:set_value(0, skip_event)
    end
    if self._pitch_range then
      self._pitch_range_value:set_text(tostring(pitch_range))
    end
  end

  local modset = rns.selected_sample_modulation_set
  local filter_type_list = rns.selected_sample_modulation_set.available_filter_types
  local filter_type = rns.selected_sample_modulation_set.filter_type
  -- Set active filter type index
  if (self._filter_type) then
    local filter_index = self:_get_filter_type_index(rns.selected_sample_modulation_set.filter_type)
    local normalized_value = self:_filter_type_to_normalized_value(filter_index)
    self._filter_type:set_value(normalized_value,skip_event)
    if self._filter_type_value then
      self._filter_type_value:set_text(filter_type)
    end
  end

  local cutoff_input = rns.selected_sample_modulation_set.cutoff_input
  if (cutoff_input and self.mappings.cutoff_input.group_name) then
    if (cutoff_input.value >= cutoff_input.value_min and
        cutoff_input.value <= cutoff_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        cutoff_input, cutoff_input.value)
      self._cutoff_input:set_value(normalized_value, skip_event)
    else
      self._cutoff_input:set_value(0, skip_event)
    end
    if self._cutoff_value then
      self._cutoff_value:set_text(cutoff_input.value_string)
    end
  end
  
  local resonance_input = rns.selected_sample_modulation_set.resonance_input
  if (resonance_input and self.mappings.resonance_input.group_name) then
    if (resonance_input.value >= resonance_input.value_min and
        resonance_input.value <= resonance_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        resonance_input, resonance_input.value)
      self._resonance_input:set_value(normalized_value, skip_event)
    else
      self._resonance_input:set_value(0, skip_event)
    end
    if self._resonance_value then
      self._resonance_value:set_text(resonance_input.value_string)
    end
  end
  
  local drive_input = rns.selected_sample_modulation_set.drive_input
  if (drive_input and self.mappings.drive_input.group_name) then
    if (drive_input.value >= drive_input.value_min and
        drive_input.value <= drive_input.value_max)
    then
      --normalize to contol range [0-1]
      local normalized_value = self:_parameter_value_to_normalized_value(
        drive_input, drive_input.value)
      self._drive_input:set_value(normalized_value, skip_event)
    else
      self._drive_input:set_value(0, skip_event)
    end
    if self._drive_value then
      self._drive_value:set_text(drive_input.value_string)
    end
  end
  
  -- fine controls
  if self._fine then
    if (self._fine_accel == 1) then
      self._fine:set(self.palette.fine_off)
    else
      self._fine:set(self.palette.fine_on)
    end
  end

end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application._build_app
-- @return bool

function InstrumentModulation:_build_app()
  TRACE("InstrumentModulation:_build_app(")

  self._parameter_sliders = {}
  self._macro_sliders = {}
  self._device_navigators = (self.mappings.device.group_name) and {} or nil

  local cm = self.display.device.control_map

  -- TODO check for required mappings
  -- if not (self.mappings.parameters.group_name or self.mappings.macros.group_name) then
  --   local msg = "InstrumentModulation cannot initialize, the required mapping 'parameters' is missing"
  --   renoise.app():show_warning(msg)
  --   return false
  -- end

  -- check if the control-map describe
  -- (1) a distributed group or (2) a grid controller
  local map = self.mappings.parameters
  local macro_map = self.mappings.macros
  --print("*** map",map.group_name)
  --print("*** map.group_name",map.group_name)
  local distributed_group = nil
  local macro_distributed_group = nil
  if (self.mappings.parameters.group_name) then
    local distributed_group = string.find(map.group_name,"*")
  end
  if (self.mappings.macros.group_name) then
    local macro_distributed_group = string.find(macro_map.group_name,"*")
  end
  local params = nil
  local macros = nil
  self._slider_grid_mode = cm:is_grid_group(map.group_name)

  if self._slider_grid_mode then
    local w,h = cm:get_group_dimensions(map.group_name)
    if (map.orientation == ORIENTATION.HORIZONTAL) then
      self._slider_group_size = h
      self._slider_max_size = w
    else
      self._slider_group_size = w
      self._slider_max_size = h
    end
  else
    self._slider_max_size = 1
    if distributed_group then
      params = cm:get_params(map.group_name,map.index)
      self._slider_group_size = #params
    else
      self._slider_group_size = cm:get_group_size(map.group_name)
    end
  end

  self._macro_slider_max_size = 1
  if macro_distributed_group then
    macros = cm:get_params(macro_map.group_name,macro_map.index)
    self._macro_slider_group_size = #macros
  else
    self._macro_slider_group_size = cm:get_group_size(macro_map.group_name)
  end

  -- if an index is given in group start from slider x

  -- if not self._slider_grid_mode and not distributed_group then
  --   self._slider_group_size = self._slider_group_size - (map.index-1)
  -- end
  
  -- if not macro_distributed_group then
  --   self._macro_slider_group_size = self._macro_slider_group_size - (map.index-1)
  -- end

  if self._slider_group_size then
    for control_index = 1,self._slider_group_size do

      -- sliders for parameters --

      local c = UISlider(self)
      c.tooltip = map.description
      if self._slider_grid_mode then
        c.group_name = map.group_name
        if (map.orientation == ORIENTATION.HORIZONTAL) then
          c:set_pos(1,control_index)
        else
          c:set_pos(control_index,1)
        end
        c:set_orientation(map.orientation)
        if (map.orientation == ORIENTATION.HORIZONTAL) then
          c:set_pos(1,control_index)
        else
          c:set_pos(control_index,1)
        end
        c.flipped = map.flipped
        c.toggleable = map.toggleable
        c.palette.background = table.rcopy(self.palette.slider_background)
        c.palette.tip = table.rcopy(self.palette.slider_tip)
        c.palette.track = table.rcopy(self.palette.slider_track)
      elseif distributed_group then
        c.group_name = params[control_index].xarg.group_name
        c:set_pos(map.index)
        c:set_size(1)
        c.toggleable = false
      else
        c.group_name = map.group_name
        c:set_pos(control_index+(map.index-1))
        c:set_size(1)
        c.toggleable = false
      end
      c.ceiling = 1

      c.on_change = function(obj) 

        obj.slider_acceleration = self._fine_accel

        local parameter_index = self._parameter_offset + control_index
        local parameters = self._parameter_set
        
        if (parameter_index > #parameters) then
          -- parameter is outside bounds
          return 

        else
          local parameter = self:_get_parameter_by_index(parameter_index)

          self:_modify_ceiling(obj,parameter)
          
          -- scale parameter value to a [0-1] range before comparing
          local normalized_value = self:_parameter_value_to_normalized_value(
            parameter, parameter.value)
          -- ignore floating point fuziness    
          if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
              obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
          then
            -- scale the [0-1] ranged value to the parameters value
            local parameter_value = self:_normalized_value_to_parameter_value(
              parameter, obj.value)
            
            -- hackily check for valid ranges, in order to suppress updates of
            -- temporarily wrong values that we get from Renoise (-1 for the meta 
            -- device effect/device choosers)    
            if (parameter_value >= parameter.value_min and 
                parameter_value <= parameter.value_max) 
            then
              parameter.value = parameter_value

              if self._record_mode then
                -- todo: proper detection of track
                local track_idx = rns.selected_track_index
                self.automation:record(track_idx,parameter,obj.value)
              end

              if self._param_values and self._param_values[control_index] then
                self._param_values[control_index]:set_text(parameter.value_string)
              end

            end
          end

        end
      end
      self._parameter_sliders[control_index] = c

    end
  end

  -- Macro parameters
  if (self.mappings.macros.group_name) then
    for control_index = 1, 8 do
      
      -- sliders for parameters --
      
      local c = UISlider(self)
      c.tooltip = map.description
      if macro_distributed_group then
        c.group_name = macro[control_index].xarg.group_name
        c:set_pos(macro_map.index)
        c:set_size(1)
        c.toggleable = false
      else
        c.group_name = macro_map.group_name
        c:set_pos(control_index+(macro_map.index-1))
        c:set_size(1)
        c.toggleable = false
      end
      c.ceiling = 1

      c.on_change = function(obj)
        
      obj.slider_acceleration = self._fine_accel

        local macro_index = control_index
        local macros = self._macro_set
        if not macros then
          return
        elseif (macro_index > #macros) then
          -- parameter is outside bounds
          return 

        else
          local macro = rns.selected_instrument.macros[macro_index]

          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (macro.value >= 0 and 
              macro.value <= 1) 
          then
            macro.value = obj.value

            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,macro,obj.value)
            end

            if self._macro_values and self._macro_values[control_index] then
              self._macro_values[control_index]:set_text(macro.value_string)
            end

          end
        end
      end
      self._macro_sliders[control_index] = c

    end
  end


  -- device navigator (optional)

  local map = self.mappings.device
  if (map.group_name) then

    local distributed_group = string.find(map.group_name,"*")
    local params = nil
    local group_size = nil
    
    if distributed_group then
      params = cm:get_params(map.group_name,map.index)
      group_size = #params
    else
      group_size = cm:get_group_size(map.group_name)
    end

    for control_index = 1,group_size do

      local group_cols = cm:count_columns(map.group_name)
      local c = UIButton(self)
      if distributed_group then
        c.group_name = params[control_index].group_name
        c:set_pos(map.index)
      else
        c.group_name = map.group_name
        c:set_pos(control_index)
      end
      c.tooltip = map.description
      c.on_press = function() 

        local inst_idx = rns.selected_instrument_index
        local track_idx = rns.selected_sample_device_chain_index
        local new_index = self:_get_device_index_by_ctrl(control_index)

        if rns.selected_sample_device_chain then
          local device = rns.instruments[inst_idx]:sample_device_chain(track_idx).devices[new_index]   

          -- select the device
          --rns.selected_sample_device_index = new_index
          self:_set_selected_sample_device_index(new_index)

          -- turn off previously selected device
          if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
            local sel_index = rns.selected_sample_device_index
            if (sel_index ~= control_index) and
                self._device_navigators[sel_index] then
              self._device_navigators[sel_index]:set(self.palette.device_nav_off)

            end
          else
            for control_index2 = 1,#self._device_navigators do
              local prm_table = self._parameter_set[control_index2]
              if prm_table and
                  (prm_table.device_index ~= new_index) then
                self._device_navigators[control_index2]:set(self.palette.device_nav_off)
              end
            end
          end
        end

      end
      self._device_navigators[control_index] = c
    end
  end

  -- device_select (optional) --
  -- select devices via knob/slider 

  local map = self.mappings.device_select
  if (map.group_name) then

    local c = UISlider(self)
    c.group_name = self.mappings.device_select.group_name
    c.tooltip = map.description
    c:set_pos(map.index or 1)
    c.palette.track = self.palette.background
    c.toggleable = false
    c.flipped = true
    c.value = 0
    c:set_orientation(map.orientation)
    c.on_change = function(obj) 
      obj.slider_acceleration = self._fine_accel
      local track_idx = rns.selected_sample_device_chain_index
      local inst_idx = rns.selected_instrument_index
      local modset_idx = rns.selected_sample_modulation_set_index
      local device = rns.selected_sample_modulation_set.devices[self._device_idx]
      local new_index = self:_get_device_index_by_ctrl(math.ceil(obj.value*self._num_devices))
      self:_set_selected_sample_modulation_device_index(new_index)

    end

    self._device_select = c

  end


  -- next parameter page

  local map = self.mappings.param_next
  if (map.group_name) then
    local c = UIButton(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.on_press = function()
      local max_offset = self._slider_group_size * 
        math.floor(#self._parameter_set/self._slider_group_size)
      self._parameter_offset = math.min(max_offset,
        self._parameter_offset + self._slider_group_size)
      self:_attach_to_parameters(false)
      self:update()
    end
    self._param_next = c
  end


  -- previous parameter page

  local map = self.mappings.param_prev
  if (map.group_name) then
    local c = UIButton(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.on_press = function()
      self._parameter_offset = math.max(0,
        self._parameter_offset - self._slider_group_size)
      self:_attach_to_parameters(false)
      self:update()
    end
    self._param_prev = c
  end


  -- next device (optional) --

  if (self.mappings.device_next.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.device_next.group_name
    c.tooltip = self.mappings.device_next.description
    c:set_pos(self.mappings.device_next.index)
    c.on_press = function()

      local device_idx = self._device_idx
      local new_index = self:_get_next_device_index(device_idx)
      self:_set_selected_sample_modulation_device_index(new_index)

    end
    self._device_next = c

  end

  -- previous device (optional) --

  if (self.mappings.device_prev.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.device_prev.group_name
    c.tooltip = self.mappings.device_prev.description
    c:set_pos(self.mappings.device_prev.index)
    c.on_press = function()

      local device_idx = self._device_idx
      local new_index = self:_get_previous_device_index(device_idx)
      self:_set_selected_sample_modulation_device_index(new_index)

    end
    self._device_prev = c

  end
  
  -- external device editor (optional) --

  if (self.mappings.ext_editor.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.ext_editor.group_name
    c.tooltip = self.mappings.ext_editor.description
    c:set_pos(self.mappings.ext_editor.index)
    c.on_press = function()

      local modset_idx = rns.selected_sample_modulation_set_index
      local device = rns.selected_sample_modulation_set.devices[self._device_idx]
      if not device then
        return
      end
      if device.is_maximized == true then
        device.is_maximized = false
      else
        device.is_maximized = true
      end

    end
    self._ext_editor = c

  end

  local map = self.mappings.device_name
  if (map) then
    local c = UILabel(self)
    c.group_name = map.group_name
    --c.tooltip = map.description
    c:set_pos(map.index)
    self._device_name = c

  end
  
  local map = self.mappings.param_names
  if (map.group_name) then
    self._param_names = {}
    local params = cm:get_params(map.group_name,map.index)
    for control_index = 1,#params do
      local c = UILabel(self)
      c.group_name = map.group_name
      c:set_pos(control_index)
      self._param_names[control_index] = c
    end
  end

  local map = self.mappings.param_values
  if (map.group_name) then
    self._param_values = {}
    local params = cm:get_params(map.group_name,map.index)
    for control_index = 1,#params do
      local c = UILabel(self)
      c.group_name = map.group_name
      c:set_pos(control_index)
      self._param_values[control_index] = c
    end
  end

  local map = self.mappings.param_active
  if (map.group_name) then
    self._param_active = {}
    local params = cm:get_params(map.group_name,map.index)
    for control_index = 1,#params do
      local c = UILed(self)
      c.group_name = params[control_index].xarg.group_name
      --c:set_pos(map.index)
      c:set_pos(control_index)
      self._param_active[control_index] = c
    end
  end
  
  local macro_map = self.mappings.macro_names
  if (macro_map.group_name) then
    self._macro_names = {}
    local macros = cm:get_params(macro_map.group_name,macro_map.index)
    for control_index = 1,#macros do
      local c = UILabel(self)
      c.group_name = macro_map.group_name
      c:set_pos(control_index)
      self._macro_names[control_index] = c
    end
  end

  local macro_map = self.mappings.macro_values
  if (macro_map.group_name) then
    self._macro_values = {}
    local macros = cm:get_params(macro_map.group_name,macro_map.index)
    for control_index = 1,#macros do
      local c = UILabel(self)
      c.group_name = macro_map.group_name
      c:set_pos(control_index)
      self._macro_values[control_index] = c
    end
  end

  -- volume input
  local map = self.mappings.volume_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].volume_input
      if (modset) then
        parameter.value = obj.value
        if self._record_mode then
          -- todo: proper detection of track
          local track_idx = rns.selected_track_index
          self.automation:record(track_idx,parameter,obj.value)
        end
      end
    end
    self._volume_input = c
  end

  -- volume input value
  local map = self.mappings.volume_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._volume_value = c
  end

  -- panning input
  local map = self.mappings.panning_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].panning_input
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_parameter_value_to_normalized_value(
          parameter, parameter.value)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_parameter_value(
            parameter, obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= parameter.value_min and 
              parameter_value <= parameter.value_max) 
          then
            parameter.value = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,parameter,obj.value)
            end
          end
        end
      end
    end
    self._panning_input = c
  end
  
  -- panning input value
  local map = self.mappings.panning_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._panning_value = c
  end
  
  -- pitch input
  local map = self.mappings.pitch_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].pitch_input
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_parameter_value_to_normalized_value(
          parameter, parameter.value)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_parameter_value(
            parameter, obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= parameter.value_min and 
              parameter_value <= parameter.value_max) 
          then
            parameter.value = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,parameter,obj.value)
            end
          end
        end
      end
    end
    self._pitch_input = c
  end

  -- pitch input value
  local map = self.mappings.pitch_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._pitch_value = c
  end

  -- pitch range
  local map = self.mappings.pitch_range
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = 1/3
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].pitch_range
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_pitch_range_to_normalized_value(
          parameter)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_pitch_range(obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= 1 and 
              parameter_value <= 96) 
          then
            modset.pitch_range = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,modset.pitch_range,obj.value)
            end
          end
        end
      end
    end
    self._pitch_range = c
  end

  -- pitch range value
  local map = self.mappings.pitch_range_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._pitch_range_value = c
  end
  
  -- filter type
  local map = self.mappings.filter_type
  if map.group_name then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
  c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = 1
    local modset = rns.selected_sample_modulation_set
    local filter_type = modset.filter_type
    local filter_type_list = modset.available_filter_types
    local filter_type_idx = self:_get_filter_type_index(rns.selected_sample_modulation_set.filter_type)
    -- scale parameter value to a [0-1] range before comparing
    local normalized_value = self:_filter_type_to_normalized_value(
    filter_type_idx)
    -- ignore floating point fuziness    
    if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
    obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
    then
      -- scale the [0-1] ranged value to the parameters value
        local parameter_value = self:_normalized_value_to_filter_type(obj.value)
        if (parameter_value >= 1 and 
            parameter_value <= #filter_type_list) 
        then
          -- the notifier will take care of the rest
          modset.filter_type = filter_type_list[parameter_value]
    end
      end

    end
    
    self._filter_type = c
  end

  -- filter type value
  local map = self.mappings.filter_type_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._filter_type_value = c
  end

  -- cutoff input
  local map = self.mappings.cutoff_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].cutoff_input
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_parameter_value_to_normalized_value(
          parameter, parameter.value)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_parameter_value(
            parameter, obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= parameter.value_min and 
              parameter_value <= parameter.value_max) 
          then
            parameter.value = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,parameter,obj.value)
            end
          end
        end
      end
    end
    self._cutoff_input = c
  end

  -- cutoff input value
  local map = self.mappings.cutoff_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._cutoff_value = c
  end
  
  -- resonance input
  local map = self.mappings.resonance_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].resonance_input
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_parameter_value_to_normalized_value(
          parameter, parameter.value)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_parameter_value(
            parameter, obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= parameter.value_min and 
              parameter_value <= parameter.value_max) 
          then
            parameter.value = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,parameter,obj.value)
            end
          end
        end
      end
    end
    self._resonance_input = c
  end

  -- resonance input value
  local map = self.mappings.resonance_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._resonance_value = c
  end
  
  -- drive input
  local map = self.mappings.drive_input
  if (map.group_name) then
    local c = UISlider(self)
    c.group_name = map.group_name
    c.tooltip = map.description
    c:set_pos(map.index)
    c.palette.track = self.palette.background
    c.on_change = function(obj)
      obj.slider_acceleration = self._fine_accel
      local inst_idx = rns.selected_instrument_index
      local modset = rns.selected_sample_modulation_set
      local modset_idx = rns.selected_sample_modulation_set_index
      local parameter = rns.instruments[inst_idx].sample_modulation_sets[modset_idx].drive_input
      if (modset) then
        -- scale parameter value to a [0-1] range before comparing
        local normalized_value = self:_parameter_value_to_normalized_value(
          parameter, parameter.value)
        -- ignore floating point fuziness    
        if (not cLib.float_compare(normalized_value, obj.value, FLOAT_COMPARE_QUANTUM) or 
            obj.value == 0.0 or obj.value == 1.0) -- be exact at the min/max 
        then
          -- scale the [0-1] ranged value to the parameters value
          local parameter_value = self:_normalized_value_to_parameter_value(
            parameter, obj.value)
          -- hackily check for valid ranges, in order to suppress updates of
          -- temporarily wrong values that we get from Renoise (-1 for the meta 
          -- device effect/device choosers)    
          if (parameter_value >= parameter.value_min and 
              parameter_value <= parameter.value_max) 
          then
            parameter.value = parameter_value
            
            if self._record_mode then
              -- todo: proper detection of track
              local track_idx = rns.selected_track_index
              self.automation:record(track_idx,parameter,obj.value)
            end
          end
        end
      end
    end
    self._drive_input = c
  end

  -- drive input value
  local map = self.mappings.drive_value
  if (map.group_name) then
    local c = UILabel(self)
    c.group_name = map.group_name
    c:set_pos(map.index)
    self._drive_value = c
  end
  
  -- Fine toggle ----------------------------
  local map = self.mappings.fine
  if map.group_name then
    local c = UIButton(self)
    c.group_name = map.group_name
    c:set_pos(map.index or 1)
    c.tooltip = map.description
    c.on_press = function()
      if (self._fine_accel == 1) then
        self:_set_fine(0.1)
      else
        self:_set_fine(1)
      end
    end
    self._fine = c
  end

  -- the finishing touches --
  self:_attach_to_song()
  Application._build_app(self)
  return true

end

--------------------------------------------------------------------------------

--- set device index, will only succeed when device exist
-- @param idx (int)

function InstrumentModulation:_set_selected_sample_modulation_device_index(idx)
  TRACE("InstrumentModulation:_set_selected_sample_modulation_device_index()",idx)

  local inst_idx = rns.selected_instrument_index  
  local modset_idx = rns.selected_sample_modulation_set_index
  local device = rns.selected_sample_modulation_set.devices[idx]
  if rns.selected_sample_modulation_set then
    if device then
      self._device_idx = idx
      self._parameter_offset = 0
      self._update_requested = true

      -- update the label
      if self._device_name then
        self._device_name:set_text(device.display_name)
      end
    end
  end
end

--------------------------------------------------------------------------------

--- update display for prev/next device-navigation buttons
-- @param device_idx (int)

function InstrumentModulation:_update_prev_next_device_buttons(device_idx)
  TRACE("InstrumentModulation:_update_prev_next_device_buttons()",device_idx)

  local inst_idx = rns.selected_instrument_index
  local modset_idx = rns.selected_sample_modulation_set_index
  local device = rns.selected_sample_modulation_set.devices[device_idx]


  local skip_event = true
  if self._device_prev and rns.selected_sample_modulation_set then
    local prev_idx = self:_get_previous_device_index(device_idx)
    local previous_device = rns.instruments[inst_idx]:sample_modulation_set(modset_idx).devices[prev_idx]
    if previous_device then
      self._device_prev:set(self.palette.prev_device_on)
    else
      self._device_prev:set(self.palette.prev_device_off)
    end
  end
  if self._device_next and rns.selected_sample_modulation_set then
    local next_idx = self:_get_next_device_index(device_idx)
    local next_device = rns.instruments[inst_idx]:sample_modulation_set(modset_idx).devices[next_idx]
    if next_device then
      self._device_next:set(self.palette.next_device_on)
    else
      self._device_next:set(self.palette.next_device_off)
    end
  end

end

--------------------------------------------------------------------------------

--- update display for external editor buttons

function InstrumentModulation:_update_ext_editor_button(device_idx)
  TRACE("InstrumentModulation:_update_prev_next_device_buttons()",device_idx)

  local skip_event = true
  if self._ext_editor then
    self._ext_editor:set(self.palette.ext_editor_off)
  end
end

--------------------------------------------------------------------------------

function InstrumentModulation:_set_fine(accel)
  TRACE("InstrumentModulation:_set_fine()",accel)

  self._fine_accel = accel
  self._update_requested = true
end

--------------------------------------------------------------------------------
-- Returns index of filter type

function InstrumentModulation:_get_filter_type_index(value)
  TRACE("InstrumentModulation:_get_filter_type_index()",value)
  local index = 1
  for i,s in ipairs(rns.selected_sample_modulation_set.available_filter_types) do
    if value == s then
      index = i
    end
  end
  return index
end


--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.start_app
-- @return bool or nil

function InstrumentModulation:start_app()
  TRACE("InstrumentModulation.start_app()")

  if not Application.start_app(self) then
    return
  end

  local new_song = false
  self:_attach_to_parameters(new_song)
  self:_attach_to_macros(new_song)
  self:_attach_to_mod_inputs(new_song)

  self:update()

end

--------------------------------------------------------------------------------

--- get specific effect parameter from current parameter-set
-- @param idx (int)
-- @return renoise.DeviceParameter

function InstrumentModulation:_get_parameter_by_index(idx)
  --TRACE("InstrumentModulation._get_parameter_by_index()",idx)

  if (self._parameter_set[idx]) then
    return self._parameter_set[idx].ref
  end

end

--------------------------------------------------------------------------------

--- obtain next device index (supports parameter subsets)
-- @param idx (int)
-- @return int

function InstrumentModulation:_get_next_device_index(idx)
  --TRACE("InstrumentModulation._get_next_device_index()",idx)

  if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
    return idx+1
  else
    for _,prm in ipairs(self._parameter_set) do
      if (idx<prm.device_index) then
        return prm.device_index
      end
    end
  end

end


--------------------------------------------------------------------------------

--- obtain previous device index (supports parameter subsets)
-- @param idx (int)
-- @return int

function InstrumentModulation:_get_previous_device_index(idx)
  TRACE("InstrumentModulation._get_previous_device_index()",idx)

  if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
    return idx-1
  else
    for _,prm in ripairs(self._parameter_set) do
      if (idx>prm.device_index) then
        return prm.device_index
      end
    end
  end

end



--------------------------------------------------------------------------------

--- obtain actual device index by specifying the control index
-- (useful when dealing with parameter subsets)
-- @param idx (int)
-- @return int

function InstrumentModulation:_get_device_index_by_ctrl(idx)
  --TRACE("InstrumentModulation._get_device_index_by_ctrl()",idx)

  if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
    return idx
  else
    local count,matched = 0,0
    for _,prm in ipairs(self._parameter_set) do
      if (prm.device_index>matched) then
        matched = prm.device_index
        count = count+1
        if (count==idx) then
          return prm.device_index
        end
      end
    end
  end

end


--------------------------------------------------------------------------------

--- obtain control index by specifying the actual device index
-- (useful when dealing with parameter subsets)
-- @param idx (int)
-- @return int

function InstrumentModulation:_get_ctrl_index_by_device(idx)
  --TRACE("InstrumentModulation._get_ctrl_index_by_device()",idx)

  if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
    return idx
  else
    local count,matched = 0,0
    for _,prm in ipairs(self._parameter_set) do
      if (prm.device_index>matched) then
        matched = prm.device_index
        count = count+1
        if (prm.device_index==idx) then
          return count
        end
      end
    end
  end

end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.on_new_document

function InstrumentModulation:on_new_document()
  TRACE("InstrumentModulation:on_new_document")
  
  self:_attach_to_song()
  
  if (self.active) then
    self:update()
  end

end


--------------------------------------------------------------------------------

--- in grid mode, when encountering a quantized parameter that
-- has a larger range than the number of buttons we lower the ceiling
-- for the slider, so only the 'settable' range is displayed
-- (called when modifying and attaching parameter) 
-- @param obj (@{Duplex.UISlider})
-- @param prm (renoise.DeviceParameter)

function InstrumentModulation:_modify_ceiling(obj,prm)
  if self._slider_grid_mode and 
    (prm.value_quantum == 1) and 
    (prm.value_max>self._slider_max_size) then
    obj.ceiling = (1/prm.value_max)*self._slider_max_size
  else
    obj.ceiling = 1
  end
end

--------------------------------------------------------------------------------

--- in non-grid mode, if the parameters is quantized and has a range of 255, 
-- we provide the 7-bit value as maximum - otherwise, we'd only be able to 
-- access every second value
-- @param prm (renoise.DeviceParameter)

function InstrumentModulation:_get_quant_max(prm)

  if (not self._slider_grid_mode) and
    (prm.value_quantum == 1) and
    (prm.value_max == 255) then
    return 127
  end
  return prm.value_max
end

--------------------------------------------------------------------------------

--- convert a [0-1] value to the given parameter value-range
-- @param parameter (renoise.DeviceParameter)
-- @param value (number)

function InstrumentModulation:_normalized_value_to_parameter_value(parameter, value)

  local value_max = self:_get_quant_max(parameter)
  local parameter_range = value_max - parameter.value_min
  return parameter.value_min + value * parameter_range
end

--------------------------------------------------------------------------------

--- convert a parameter value to a [0-1] value 
-- @param parameter (renoise.DeviceParameter)
-- @param value (number)

function InstrumentModulation:_parameter_value_to_normalized_value(parameter, value)

  local value_max = self:_get_quant_max(parameter)
  local parameter_range = value_max - parameter.value_min
  return (value - parameter.value_min) / parameter_range

end

--------------------------------------------------------------------------------

--- convert a [0-1] value to the given parameter value-range
-- @param value (number)

function InstrumentModulation:_normalized_value_to_pitch_range(value)
  return math.floor(1 + value * 95)
end

--------------------------------------------------------------------------------

--- convert a parameter value to a [0-1] value 
-- @param pitch_range (number)

function InstrumentModulation:_pitch_range_to_normalized_value(pitch_range)
  return (pitch_range - 1) / 95
end

--------------------------------------------------------------------------------

--- convert a filter type index to a [0-1] value 
-- @param pitch_range (number)

function InstrumentModulation:_filter_type_to_normalized_value(filter_type)
  return (filter_type - 1) / #rns.selected_sample_modulation_set.available_filter_types
end

--------------------------------------------------------------------------------

--- convert a [0-1] value to the given filter type index
-- @param value (number)

function InstrumentModulation:_normalized_value_to_filter_type(value)
  return math.floor(1 + value * #rns.selected_sample_modulation_set.available_filter_types)
end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.on_idle

function InstrumentModulation:on_idle()

  if (not self.active) then 
    return 
  end

  if self._track_update_requested then
    self._track_update_requested = false
    self._parameter_offset = 0
    self:_attach_to_track_devices(rns.selected_sample_modulation_set)
    self._update_requested = true
  end

  if self._update_requested then
    self:_attach_to_parameters()
    self:_attach_to_macros()
    self:_attach_to_mod_inputs()
    self._update_requested = false
    self:update()
  end

  Automateable.on_idle(self)

end


--------------------------------------------------------------------------------

--- update the current parameter set 
-- (updates InstrumentModulation._num_devices)

function InstrumentModulation:_define_parameters()
  TRACE("InstrumentModulation:_define_parameters()")

  self._parameter_set = table.create()
  local inst_idx = rns.selected_instrument_index
  local modset_idx = rns.selected_sample_modulation_set_index
  local device = rns.selected_sample_modulation_set.devices[self._device_idx]
  if (self.options.include_parameters.value == ALL_PARAMETERS) then
    if device then
      for _,parameter in ipairs(device.parameters) do
        self._parameter_set:insert({
          device_index=self._device_idx,
          ref=parameter
        })
      end
    end
    if rns.selected_sample_modulation_set then
      self._num_devices = #rns.instruments[inst_idx]:sample_modulation_set(modset_idx).devices
    end
  else
    local track = rns.selected_sample_device_chain
    for device_idx,device in ipairs(track.devices) do
      for _,parameter in ipairs(device.parameters) do
        if(parameter.show_in_mixer) and
            (self.options.include_parameters.value == MIXER_PARAMETERS) then
          self._parameter_set:insert({
            device_index=device_idx,
            ref=parameter
          })
        elseif (parameter.is_automated) and
            (self.options.include_parameters.value == AUTOMATED_PARAMETERS) then
          self._parameter_set:insert({
            device_index=device_idx,
            ref=parameter
          })
        end
      end
    end
  end

end

--------------------------------------------------------------------------------

--- update the current parameter set 
-- (updates InstrumentModulation._num_devices)

function InstrumentModulation:_define_macros()
  TRACE("InstrumentModulation:_define_macros()")

  self._macro_set = table.create()
  local inst = rns.selected_instrument   
  if inst then
    for _,macro in ipairs(inst.macros) do
      self._macro_set:insert(macro)
    end
  end
end


--------------------------------------------------------------------------------

--- update the number of devices in the current parameter set 
-- (updates InstrumentModulation._num_devices)

function InstrumentModulation:_get_num_devices()
  TRACE("InstrumentModulation:_get_num_devices()")

  if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
    local inst_idx = rns.selected_instrument_index 
    local modset_idx = rns.selected_sample_modulation_set_index
    --self._num_devices = #rns.tracks[track_idx].devices
    if rns.selected_sample_device_chain then
      self._num_devices = #rns.instruments[inst_idx]:sample_modulation_set(modset_idx).devices
    end
  else
    local devices = {}
    local device_count = 0
    local track = rns.selected_sample_device_chain
    for device_idx,device in ipairs(track.devices) do
      for _,parameter in ipairs(device.parameters) do
        local matched = false
        if(parameter.show_in_mixer) and
            (self.options.include_parameters.value == MIXER_PARAMETERS) then
          matched = true
        elseif (parameter.is_automated) and
            (self.options.include_parameters.value == AUTOMATED_PARAMETERS) then
          matched = true
        end
        if matched and not devices[device_idx] then
          devices[device_idx] = true -- "something"
          device_count = device_count +1           
        end
      end
    end

    self._num_devices = device_count

  end

end

--------------------------------------------------------------------------------

--- update display of the parameter navigation buttons

function InstrumentModulation:update_param_page()
  TRACE("InstrumentModulation:update_param_page()")

  if self._param_next then
    if ((self._parameter_offset + self._slider_group_size) 
      < #self._parameter_set)
    then
      self._param_next:set(self.palette.next_param_on)
    else
      self._param_next:set(self.palette.next_param_off)
    end
  end
  if self._param_prev then
    if (self._parameter_offset > 0) then
      self._param_prev:set(self.palette.prev_param_on)
    else
      self._param_prev:set(self.palette.prev_param_off)
    end
  end

end

--------------------------------------------------------------------------------

--- adds notifiers to song
-- invoked when a new document becomes available

function InstrumentModulation:_attach_to_song()
  TRACE("InstrumentModulation:_attach_to_song()")

  
  -- update on parameter changes in the song
  rns.selected_sample_device_observable:add_notifier(
    function()
      TRACE("InstrumentModulation:selected_sample_device_observable fired...")
      -- always update when display all parameters 
      if (self.options.include_parameters.value == ALL_PARAMETERS or CUSTOM_PARAMETERS) then
        self._update_requested = true
      end
      -- update the device selector
      if self._device_select then
        self._update_requested = true
      end

    end
  )
  
  -- update on macro changes in the song
  rns.selected_instrument_observable:add_notifier(
    function()
      TRACE("InstrumentModulation:selected_instrument_observable fired...")
      -- always update when display all parameters 
      self._track_update_requested = true
      -- update the device selector
      self:_get_num_devices()
    end 
  )
  
  -- update on sample mod chain change
  rns.selected_sample_modulation_set_observable:add_notifier(
    function()
      TRACE("InstrumentModulation:selected_instrument_observable fired...")
      -- always update when display all parameters 
      self._track_update_requested = true

      -- update the device selector
      self:_get_num_devices()
    end 
  )

  Automateable._attach_to_song(self)

  -- immediately attach to the current parameter set
  local new_song = true
  self:_attach_to_parameters(new_song)
  self:_attach_to_macros(new_song)
  self:_attach_to_track_devices(rns.selected_sample_modulation_set,new_song)


end

--------------------------------------------------------------------------------

--- attach notifier methods to devices & parameters...
-- @param track (renoise.Track)
-- @param new_song (bool)

function InstrumentModulation:_attach_to_track_devices(track,new_song)
  TRACE("InstrumentModulation:_attach_to_track_devices",track,new_song)


  -- remove notifier first 
  self:_remove_notifiers(new_song,self._device_observables)
  self:_remove_notifiers(new_song,self._mixer_observables)
  self:_remove_notifiers(new_song,self._preset_observables)

  self._device_observables = table.create()

  -- handle changes to devices in track
  -- todo: only perform update when in current track
  if not track then
    return
  end
    
  if (track.devices_observable) then
    self._device_observables:insert(track.devices_observable)
    track.devices_observable:add_notifier(
      function()
        TRACE("InstrumentModulation:devices_observable fired...")
        self._track_update_requested = true
        
        -- tracks may have been inserted or removed
        self:_get_num_devices()
        
    end
    )
  end
  
end

--------------------------------------------------------------------------------

--- detect when a parameter set has changed
-- @param new_song (bool) true to leave existing notifiers alone

function InstrumentModulation:_attach_to_parameters(new_song)
  TRACE("InstrumentModulation:_attach_to_parameters", new_song)

  if not self.active or not self.mappings.parameters.group_name then
    return
  end

    -- if no device is selected, select the TrackVolPan device
  if (self._device_idx==0) then
    --rns.selected_sample_device_index = 1
    self._device_idx = 1
  end


  self:_define_parameters()
  self:_get_num_devices()

  local cm = self.display.device.control_map

  -- validate and update the sequence/parameter offset
  self:update_param_page()

  self:_remove_notifiers(new_song,self._parameter_observables)
  
  -- then attach to the new ones in the order we want them
  for control_index = 1, self._slider_group_size do
    local parameter_index = self._parameter_offset + control_index
    local parameter = self:_get_parameter_by_index(parameter_index)
    local control = self._parameter_sliders[control_index]
    local outside_bounds = (parameter_index>#self._parameter_set)

    --print("*** control_index, parameter_index,#self._parameter_set",control_index,parameter_index,#self._parameter_set)

    -- different tooltip for unassigned controls
    local tooltip = outside_bounds and "Instrument Modulation: param N/A" or 
      string.format("Instrument Modulation param : %s",parameter.name)
    control.tooltip = tooltip

    -- assign background color
    if self._slider_grid_mode then
      if (outside_bounds or not parameter) then
        control:set_palette({background=self.palette.background})
      else
        control:set_palette({background=self.palette.slider_background})
      end
    end

    if(parameter) then
      -- if value is quantized, and we are dealing with a grid 
      -- controller, resize the slider to fit the quantized values
      if self._slider_grid_mode then
        if (parameter.value_quantum==1) then
          control:set_size(math.min(parameter.value_max,self._slider_max_size))
        else
          control:set_size(self._slider_max_size)
        end
      end

      self:_modify_ceiling(control,parameter)

      self._parameter_observables:insert(parameter.value_observable)
      parameter.value_observable:add_notifier(
        self, 
        function()
          if (self.active) then

            -- TODO skip value-tracking when we are recording automation

            -- scale parameter value to a [0-1] range
            local normalized_value = self:_parameter_value_to_normalized_value(
              parameter, parameter.value) 
            -- ignore floating point fuzziness    
            if (not cLib.float_compare(normalized_value, control.value, FLOAT_COMPARE_QUANTUM) or
                normalized_value == 0.0 or normalized_value == 1.0) -- be exact at the min/max 
            then
              local skip_event = true -- only update the Duplex UI
              self:set_parameter(control_index, normalized_value, skip_event)

              if self._param_values and self._param_values[control_index] then
                self._param_values[control_index]:set_text(parameter.value_string)
              end

            end
          end
        end 
      )
    end
    
    if self._param_names and self._param_names[control_index] then
       local param_name = "-"
       if (parameter) then
         for _, custom_list in ipairs(custom) do
           param_name = parameter.name
         end
       else
         param_name = "-"
       end
      self._param_names[control_index]:set_text(param_name)
    end
    
    if self._param_values and self._param_values[control_index] then
     local param_value = parameter and parameter.value_string or ""
     self._param_values[control_index]:set_text(param_value)
    end

  end

  self.display:apply_tooltips(self.mappings.parameters.group_name)

end

--------------------------------------------------------------------------------

--- detect when a parameter set has changed
-- @param new_song (bool) true to leave existing notifiers alone

function InstrumentModulation:_attach_to_macros(new_song)
  TRACE("InstrumentModulation:_attach_to_macros", new_song)

  if not self.active or not self.mappings.macros.group_name then
    return
  end
  self:_define_macros()
  local cm = self.display.device.control_map

  self:_remove_notifiers(new_song,self._macro_observables)
  
  -- then attach to the new ones in the order we want them
  for control_index = 1,self._macro_slider_group_size do
    local macro_index = control_index
    local macro = rns.selected_instrument.macros[macro_index]
    local control = self._macro_sliders[control_index]
    local observed = nil
    local outside_bounds = (macro_index>#self._macro_set)
    --print("*** control_index, parameter_index,#self._parameter_set",control_index,parameter_index,#self._parameter_set)

    -- different tooltip for unassigned controls
    local tooltip = outside_bounds and "Instrument Modulation: macro N/A" or 
      string.format("Instrument Modulation macro : %s",macro.name)
    control.tooltip = tooltip

    -- assign background color
    if self._macro_slider_grid_mode then
      if (outside_bounds or not macro) then
        control:set_palette({background=self.palette.background})
      else
        control:set_palette({background=self.palette.slider_background})
      end
    end

    if(macro) then
      self._macro_observables:insert(macro.value_observable)
      macro.value_observable:add_notifier(
        function()
          if (self.active) then
            -- TODO skip value-tracking when we are recording automation

            local skip_event = true -- only update the Duplex UI
            local value = macro.value
            self:set_macro(control_index, value, skip_event)
            if self._macro_values and self._macro_values[control_index] then
              self._macro_values[control_index]:set_text(macro.value_string)
            end

            observed = true

          end
        end 
      )
    end

    if(macro and not observed) then
      local skip_event = true -- only update the Duplex UI
      local value = macro.value
      self:set_macro(control_index, value, skip_event)
      if self._macro_values and self._macro_values[control_index] then
        self._macro_values[control_index]:set_text(macro.value_string)
      end
    end
      
    
    if self._macro_names and self._macro_names[control_index] then
       local macro_name = "-"
       if (macro) then
         macro_name = macro.name
       else
         param_name = "-"
       end
      self._macro_names[control_index]:set_text(macro_name)
    end
    
    if self._macro_values and self._macro_values[control_index] then
     local macro_value = macro and macro.value_string or ""
     self._macro_values[control_index]:set_text(macro_value)
    end

  end

  self.display:apply_tooltips(self.mappings.macros.group_name)

end

--------------------------------------------------------------------------------

--- detect when a mod input or set has changed
-- @param new_song (bool) true to leave existing notifiers alone

function InstrumentModulation:_attach_to_mod_inputs(new_song)
  TRACE("InstrumentModulation:_attach_to_mod_inputs", new_song)

  if not self.active or not rns.selected_sample_modulation_set then
    return
  end
  local cm = self.display.device.control_map

  self:_remove_notifiers(new_song,self._mod_input_observables)

  -- Volume input
  local volume_input = rns.selected_sample_modulation_set.volume_input
  -- different tooltip for unassigned controls
  local volume_input_observed = nil

  if(volume_input and self.mappings.volume_input.group_name) then
    local volume_input_control = self._volume_input
    local vi_tooltip = "Volume Input"
    volume_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(volume_input.value_observable)
    volume_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local value = volume_input.value
          self._volume_input:set_value(value, skip_event)
          if(self.mappings.volume_value and self._volume_value) then
            self._volume_value:set_text(volume_input.value_string)
          end
          
          volume_input_observed = true
          
        end
      end 
    )
  end

  if(volume_input and not volume_input_observed) then
    if (self.mappings.volume_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local value = volume_input.value
      self._volume_input:set_value(value, skip_event)
      if(self.mappings.volume_value and self._volume_value) then
        self._volume_value:set_text(volume_input.value_string)
      end
    end
  end

  if(self.mappings.volume_value and self._volume_value) then
    local value = volume_input and volume_input.value_string or ""
    self._volume_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.volume_input.group_name)

  -- Panning input
  local panning_input = rns.selected_sample_modulation_set.panning_input
  -- different tooltip for unassigned controls
  local panning_input_observed = nil

  if(panning_input and self.mappings.panning_input.group_name) then
    local panning_input_control = self._panning_input
    local vi_tooltip = "Panning Input"
    panning_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(panning_input.value_observable)
    panning_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_parameter_value_to_normalized_value(
        panning_input, panning_input.value)
          self._panning_input:set_value(normalized_value, skip_event)
          if(self.mappings.panning_value and self._panning_value) then
            self._panning_value:set_text(panning_input.value_string)
          end
          
          panning_input_observed = true
          
        end
      end 
    )
  end

  if(panning_input and not panning_input_observed) then
    if (self.mappings.panning_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_parameter_value_to_normalized_value(
        panning_input, panning_input.value)
      self._panning_input:set_value(normalized_value, skip_event)
      if(self.mappings.panning_value and self._panning_value) then
        self._panning_value:set_text(panning_input.value_string)
      end
    end
  end

  if(self.mappings.panning_value and self._panning_value) then
    local value = panning_input and panning_input.value_string or ""
    self._panning_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.panning_input.group_name)

  -- Pitch input
  local pitch_input = rns.selected_sample_modulation_set.pitch_input
  -- different tooltip for unassigned controls
  local pitch_input_observed = nil

  if(pitch_input and self.mappings.pitch_input.group_name) then
    local pitch_input_control = self._pitch_input
    local vi_tooltip = "Pitch Input"
    pitch_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(pitch_input.value_observable)
    pitch_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_parameter_value_to_normalized_value(
        pitch_input, pitch_input.value)
          self._pitch_input:set_value(normalized_value, skip_event)

          if(self.mappings.pitch_value and self._pitch_value) then
            self._pitch_value:set_text(pitch_input.value_string)
          end
          
          pitch_input_observed = true
          
        end
      end 
    )
  end

  if(pitch_input and not pitch_input_observed) then
    if (self.mappings.pitch_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_parameter_value_to_normalized_value(
        pitch_input, pitch_input.value)
      self._pitch_input:set_value(normalized_value, skip_event)
      if(self.mappings.pitch_value and self._pitch_value) then
        self._pitch_value:set_text(pitch_input.value_string)
      end
    end
  end

  if(self.mappings.pitch_value and self._pitch_value) then
    local value = pitch_input and pitch_input.value_string or ""
    self._pitch_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.pitch_input.group_name)

  -- Pitch range
  local modset = rns.selected_sample_modulation_set
  local pitch_range = modset.pitch_range
  -- different tooltip for unassigned controls
  local pitch_range_observed = nil

  if(pitch_range and self.mappings.pitch_range.group_name) then
    local pitch_range_control = self._pitch_range
    local vi_tooltip = "Pitch Range"
    pitch_range_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(modset.pitch_range_observable)
    modset.pitch_range_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_pitch_range_to_normalized_value(
        modset.pitch_range)
          self._pitch_range:set_value(normalized_value, skip_event)

          if(self.mappings.pitch_range_value and self._pitch_range_value) then
            self._pitch_range_value:set_text(tostring(modset.pitch_range))
          end
          
          pitch_range_observed = true
          
        end
      end 
    )
  end

  if(pitch_range and not pitch_range_observed) then
    if (self.mappings.pitch_range.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_pitch_range_to_normalized_value(
        modset.pitch_range)
      self._pitch_range:set_value(normalized_value, skip_event)
      if(self.mappings.pitch_range_value and self._pitch_range_value) then
        self._pitch_range_value:set_text(tostring(modset.pitch_range))
      end
    end
  end

  if(self.mappings.pitch_range_value and self._pitch_range_value) then
    local value = pitch_range and tostring(modset.pitch_range) or ""
    self._pitch_range_value:set_text(value)
  end
  
  self.display:apply_tooltips(self.mappings.pitch_range.group_name)

  -- Filter Type
  local modset = rns.selected_sample_modulation_set
  local filter_type = modset.filter_type
  -- different tooltip for unassigned controls
  local filter_type_observed = nil

  if(filter_type and self.mappings.filter_type.group_name) then

    local filter_type_control = self._filter_type
    local vi_tooltip = "Cutoff Input"
    filter_type_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(modset.filter_type_observable)
    modset.filter_type_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local filter_index = self:_get_filter_type_index(rns.selected_sample_modulation_set.filter_type)
      local normalized_value = self:_filter_type_to_normalized_value(filter_index)
          self._filter_type:set_value(normalized_value,skip_event)

          if self._filter_type_value then
            self._filter_type_value:set_text(modset.filter_type)
          end

          filter_type_observed = true
          
        end
      end 
    )
  end

  if(filter_type and not filter_type_observed) then
    if (self.mappings.filter_type.group_name) then
      local skip_event = true -- only update the Duplex UI
      local filter_index = self:_get_filter_type_index(rns.selected_sample_modulation_set.filter_type)
      local normalized_value = self:_filter_type_to_normalized_value(filter_index)
      self._filter_type:set_value(normalized_value,skip_event)
      if self._filter_type_value then
        self._filter_type_value:set_text(modset.filter_type)
      end
    end
  end

  if(self.mappings.filter_type_value and self._filter_type_value) then
    local value = modset.filter_type or ""
    self._filter_type_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.filter_type.group_name)

  -- Cutoff input
  local cutoff_input = rns.selected_sample_modulation_set.cutoff_input
  -- different tooltip for unassigned controls
  local cutoff_input_observed = nil

  if(cutoff_input and self.mappings.cutoff_input.group_name) then
    local cutoff_input_control = self._cutoff_input
    local vi_tooltip = "Cutoff Input"
    cutoff_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(cutoff_input.value_observable)
    cutoff_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_parameter_value_to_normalized_value(
        cutoff_input, cutoff_input.value)
          self._cutoff_input:set_value(normalized_value, skip_event)
          if(self.mappings.cutoff_value and self._cutoff_value) then
            self._cutoff_value:set_text(cutoff_input.value_string)
          end
          
          cutoff_input_observed = true
          
        end
      end 
    )
  end

  if(cutoff_input and not cutoff_input_observed) then
    if (self.mappings.cutoff_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_parameter_value_to_normalized_value(
        cutoff_input, cutoff_input.value)
      self._cutoff_input:set_value(normalized_value, skip_event)
      if(self.mappings.cutoff_value and self._cutoff_value) then
        self._cutoff_value:set_text(cutoff_input.value_string)
      end
    end
  end

  if(self.mappings.cutoff_value and self._cutoff_value) then
    local value = cutoff_input and cutoff_input.value_string or ""
    self._cutoff_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.cutoff_input.group_name)

  -- Resonance input
  local resonance_input = rns.selected_sample_modulation_set.resonance_input
  -- different tooltip for unassigned controls
  local resonance_input_observed = nil

  if(resonance_input and self.mappings.resonance_input.group_name) then
    local resonance_input_control = self._resonance_input
    local vi_tooltip = "Resonance Input"
    resonance_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(resonance_input.value_observable)
    resonance_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_parameter_value_to_normalized_value(
            resonance_input, resonance_input.value)
          self._resonance_input:set_value(normalized_value, skip_event)
          if(self.mappings.resonance_value and self._resonance_value) then
            self._resonance_value:set_text(resonance_input.value_string)
          end
          
          resonance_input_observed = true
          
        end
      end 
    )
  end

  if(resonance_input and not resonance_input_observed) then
    if (self.mappings.resonance_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_parameter_value_to_normalized_value(
        resonance_input, resonance_input.value)
      self._resonance_input:set_value(normalized_value, skip_event)
      if(self.mappings.resonance_value and self._resonance_value) then
        self._resonance_value:set_text(resonance_input.value_string)
      end
    end
  end

  if(self.mappings.resonance_value and self._resonance_value) then
    local value = resonance_input and resonance_input.value_string or ""
    self._resonance_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.resonance_input.group_name)

  -- Drive input
  local drive_input = rns.selected_sample_modulation_set.drive_input
  -- different tooltip for unassigned controls
  local drive_input_observed = nil

  if(drive_input and self.mappings.drive_input.group_name) then
    local drive_input_control = self._drive_input
    local vi_tooltip = "Drive Input"
    drive_input_control.tooltip = vi_tooltip
    self._mod_input_observables:insert(drive_input.value_observable)
    drive_input.value_observable:add_notifier(
      function()
        if (self.active) then
          -- TODO skip value-tracking when we are recording automation
          
          local skip_event = true -- only update the Duplex UI
          local normalized_value = self:_parameter_value_to_normalized_value(
            drive_input, drive_input.value)
          self._drive_input:set_value(normalized_value, skip_event)
          if(self.mappings.drive_value and self._drive_value) then
            self._drive_value:set_text(drive_input.value_string)
          end
          
          drive_input_observed = true
          
        end
      end 
    )
  end

  if(drive_input and not drive_input_observed) then
    if (self.mappings.drive_input.group_name) then
      local skip_event = true -- only update the Duplex UI
      local normalized_value = self:_parameter_value_to_normalized_value(
        drive_input, drive_input.value)
      self._drive_input:set_value(normalized_value, skip_event)
      if(self.mappings.drive_value and self._drive_value) then
        self._drive_value:set_text(drive_input.value_string)
      end
    end
  end

  if(self.mappings.drive_value and self._drive_value) then
    local value = drive_input and drive_input.value_string or ""
    self._drive_value:set_text(value)
  end

  self.display:apply_tooltips(self.mappings.drive_input.group_name)

end

--------------------------------------------------------------------------------

--- detach all previously attached notifiers first
-- but don't even try to detach when a new song arrived. old observables
-- will no longer be alive then...
-- @param new_song (bool), true to leave existing notifiers alone
-- @param observables (table), list of observables

function InstrumentModulation:_remove_notifiers(new_song,observables)

  if (not new_song) then
    for _,observable in pairs(observables) do
      -- temp security hack. can also happen when removing FX
      pcall(function() observable:remove_notifier(self) end)
    end
  end
    
  observables:clear()

end

