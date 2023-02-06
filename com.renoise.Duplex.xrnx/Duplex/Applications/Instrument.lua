--[[============================================================================
-- Duplex.Application.Instrument
============================================================================]]--

--[[--

Take control of the Renoise Instrument.

#

[View the README.md](https://github.com/renoise/xrnx/blob/master/Tools/com.renoise.Duplex.xrnx/Docs/Applications/Instrument.md) (github)

--]]


--==============================================================================


class 'Instrument' (Application)

--Instrument.default_options = {}

Instrument.available_mappings = {
  prev_scale = {
    description = "Instrument: select the previous harmonic scale",
  },
  next_scale = {
    description = "Instrument: select the next harmonic scale",
  },
  label_scale = {
    description = "Instrument: display name of current scale",
  },
  set_key = {
    description = "Instrument: select the harmonic key",
    orientation = ORIENTATION.HORIZONTAL,
    flipped = true,
  },
  inst_next = {
    description = "Instrument: Select next instrument",
    component = UIButton,
  },
  inst_prev = {
    description = "Instrument: Select previous instrument",
    component = UIButton,
  },
  inst_name = {
    description = "Instrument: Display instrument name",
    component = UILabel,
  },
  chain_name = {
    description = "Instrument: Display FX chain name",
    component = UILabel,
  },
  chain_prev = {
    description = "Instrument: Select previous sample device chain",
    component = UIButton,
  },
  chain_next = {
    description = "Instrument: Select next sample device chain",
    component = UILabel,
  },
  modset_name = {
    description = "Instrument: Display modulation set name",
    component = UILabel,
  },
  modset_prev = {
    description = "Instrument: Select previous modulation set",
    component = UIButton,
  },
  modset_next = {
    description = "Instrument: Select next modulation set",
    component = UILabel,
  },
  preset_name = {
    description = "Instrument: Display preset name",
    component = UILabel,
  },
  parameters = {
    description = "Instrument: Parameter value",
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
    description = "Instrument: Next Parameter page",
    component = UIButton,
    distributable = true,
  },
  param_prev = {
    description = "Instrument: Previous Parameter page",
    component = UIButton,
    distributable = true,
  },
  program_name = {
    description = "Instrument: Display program name",
    component = UILabel,
  },
  param_names = {
    description = "Instrument: Display parameter name",
    distributable = true,
    greedy = true,
  },
  param_values = {
    description = "Instrument: Display parameter value",
    distrubutable = true,
    greedy = true,
  },
  program_next = { 
    description = "Effect: Select next program preset",
    component = UIButton,
  },
  program_prev = {
    description = "Effect: Select previous program preset",
    component = UIButton,
  },
}

Instrument.default_palette = {
 
  scale_prev_enabled  = { color = {0xFF,0xff,0xff}, text="-≣", val=true  },
  scale_prev_disabled = { color = {0x00,0x00,0x00}, text="-≣", val=false },
  scale_next_enabled  = { color = {0xFF,0xff,0xff}, text="+≣", val=true  },
  scale_next_disabled = { color = {0x00,0x00,0x00}, text="+≣", val=false },
  
  -- instrument buttons
  inst_prev_on  = { color = {0xFF,0xff,0xff}, text="Inst. ◄", val=true  },
  inst_prev_off = { color = {0x00,0x00,0x00}, text="Inst. ◄", val=false },
  inst_next_on = { color = {0xFF,0xff,0xff}, text="Inst. ►", val=true  },
  inst_next_off = { color = {0x00,0x00,0x00}, text="Inst. ►", val=false },
  
  -- chain buttons
  chain_prev_on  = { color = {0xFF,0xff,0xff}, text="Ch. ◄", val=true  },
  chain_prev_off = { color = {0x00,0x00,0x00}, text="Ch. ◄", val=false },
  chain_next_on = { color = {0xFF,0xff,0xff}, text="Ch. ►", val=true  },
  chain_next_off = { color = {0x00,0x00,0x00}, text="Ch. ►", val=false },
  
  -- chain buttons
  modset_prev_on  = { color = {0xFF,0xff,0xff}, text="Ch. ◄", val=true  },
  modset_prev_off = { color = {0x00,0x00,0x00}, text="Ch. ◄", val=false },
  modset_next_on = { color = {0xFF,0xff,0xff}, text="Ch. ►", val=true  },
  modset_next_off = { color = {0x00,0x00,0x00}, text="Ch. ►", val=false },

  key_select_enabled   = { color = {0xFF,0xff,0xff}, val=true  },
  key_select_disabled  = { color = {0x00,0x00,0x00}, text="·", val=false },

}

Instrument.SCALE_KEYS = { "C","C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B" }



--------------------------------------------------------------------------------

--- Constructor method
-- @param (VarArg)
-- @see Duplex.Application

function Instrument:__init(...)
  TRACE("Instrument:__init", ...)
  
  self._controls = {}
  self._chain_name = nil
  self._modset_name = nil
  self._inst_name = nil
  
  Application.__init(self,...)
  --self:list_mappings_and_options(Instrument)


end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.start_app
-- @return bool or nil

function Instrument:start_app()

  if not Application.start_app(self) then
    return
  end
  self:update()

end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application._build_app
-- @return bool

function Instrument:_build_app()

  local map = self.mappings.prev_scale
  if map.group_name then
    local c = UIButton(self,map)
    c.on_press = function(obj)
      xInstrument.set_previous_scale(rns.selected_instrument)
    end
    c.on_hold = function(obj)
      rns.selected_instrument.trigger_options.scale_mode = "None"
    end
    self._controls.prev_scale = c
  end

  local map = self.mappings.next_scale
  if map.group_name then
    local c = UIButton(self,map)
    c.on_press = function(obj)
      xInstrument.set_next_scale(rns.selected_instrument)
    end
    c.on_hold = function(obj)
      xInstrument.set_scale_by_index(rns.selected_instrument,#xScale.SCALES)
    end
    self._controls.next_scale = c
  end

  local map = self.mappings.set_key
  if map.group_name then
    
    -- assigned to buttons?
    local slider_size = 1
    local cm = self.display.device.control_map
    if (cm:is_grid_group(map.group_name)) then
      slider_size = cm:get_group_size(map.group_name)
      --map.orientation = ORIENTATION.NONE
    end
    --print("slider_size",slider_size)

    local c = UISlider(self,map)
    c:set_size(slider_size)
    c.on_change = function()
      local instr = rns.selected_instrument
      instr.trigger_options.scale_key = c.index
    end
    self._controls.set_key = c
  end
  
  -- previous instrument
  if (self.mappings.inst_prev.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.inst_prev.group_name
    c.tooltip = self.mappings.inst_prev.description
    c:set_pos(self.mappings.inst_prev.index)
    c.on_press = function()

      local inst_idx = rns.selected_instrument_index
      if (inst_idx ~= 1) then
        rns.selected_instrument_index = inst_idx - 1
      end

    end
    self._inst_prev = c

  end
  
  -- next instrument
  if (self.mappings.inst_next.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.inst_next.group_name
    c.tooltip = self.mappings.inst_next.description
    c:set_pos(self.mappings.inst_next.index)
    c.on_press = function()

      local inst_idx = rns.selected_instrument_index
      if (rns.instruments[inst_idx+1]) then
        rns.selected_instrument_index = inst_idx + 1
      end

    end
    self._inst_next = c

  end
  
  -- previous fx chain
  if (self.mappings.chain_prev.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.chain_prev.group_name
    c.tooltip = self.mappings.chain_prev.description
    c:set_pos(self.mappings.chain_prev.index)
    c.on_press = function()

      local chain_idx = rns.selected_sample_device_chain_index
      if (chain_idx ~= 1) then
        rns.selected_sample_device_chain_index = chain_idx - 1
      end

    end
    self._chain_prev = c

  end
  
  -- next fx chain
  if (self.mappings.chain_next.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.chain_next.group_name
    c.tooltip = self.mappings.chain_next.description
    c:set_pos(self.mappings.chain_next.index)
    c.on_press = function()

      local chain_idx = rns.selected_sample_device_chain_index
      if (rns.selected_instrument.sample_device_chains[chain_idx+1]) then
        rns.selected_sample_device_chain_index = chain_idx + 1
      end

    end
    self._chain_next = c

  end
  
  local map = self.mappings.chain_name
  if (map) then
    local c = UILabel(self)
    c.group_name = map.group_name
    --c.tooltip = map.description
    c:set_pos(map.index)
    self._chain_name = c

  end
  
  -- previous modulation set
  if (self.mappings.modset_prev.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.modset_prev.group_name
    c.tooltip = self.mappings.modset_prev.description
    c:set_pos(self.mappings.modset_prev.index)
    c.on_press = function()

      local modset_idx = rns.selected_sample_modulation_set_index
      if (modset_idx ~= 1) then
        rns.selected_sample_modulation_set_index = modset_idx - 1
      end

    end
    self._modset_prev = c

  end
  
  -- next modulation set
  if (self.mappings.modset_next.group_name) then

    local c = UIButton(self)
    c.group_name = self.mappings.modset_next.group_name
    c.tooltip = self.mappings.modset_next.description
    c:set_pos(self.mappings.modset_next.index)
    c.on_press = function()

      local modset_idx = rns.selected_sample_modulation_set_index
      if (rns.selected_instrument.sample_modulation_sets[modset_idx+1]) then
        rns.selected_sample_modulation_set_index = modset_idx + 1
      end

    end
    self._modset_next = c

  end
  
  local map = self.mappings.modset_name
  if (map) then
    local c = UILabel(self)
    c.group_name = map.group_name
    --c.tooltip = map.description
    c:set_pos(map.index)
    self._modset_name = c

  end
  
  local map = self.mappings.inst_name
  if (map) then
    local c = UILabel(self)
    c.group_name = map.group_name
    --c.tooltip = map.description
    c:set_pos(map.index)
    self._inst_name = c

  end

  -- attach to song at first run
  self:_attach_to_song()

  return true

end

--------------------------------------------------------------------------------

--- set button to current state

function Instrument:update()

  self:update_scale_controls()
  self:_update_instrument_controls()
  self:_update_chain_controls()
  self:_update_modset_controls()
  self:update_chain_name()


end

--- set button to current state

function Instrument:update_chain_name()

  if self._chain_name then
    local chain_idx = rns.selected_sample_device_chain_index
    if (rns.selected_instrument.sample_device_chains[chain_idx]) then
      self._chain_name:set_text(rns.selected_instrument.sample_device_chains[chain_idx].name)
    else
      self._chain_name:set_text("-")
    end
  end

end

--- set button to current state

function Instrument:update_modset_name()

  if self._modset_name then
    local modset_idx = rns.selected_sample_modulation_set_index
    if (rns.selected_instrument.sample_modulation_sets[modset_idx]) then
      self._modset_name:set_text(rns.selected_instrument.sample_modulation_sets[modset_idx].name)
    else
      self._modset_name:set_text("-")
    end
  end

end

--- set button to current state

function Instrument:update_inst_name()

  if self._inst_name then
    local inst = rns.selected_instrument
    if (inst.name) then
      self._inst_name:set_text(inst.name)
    else
      self._inst_name:set_text("-")
    end
  end

end

--------------------------------------------------------------------------------

--- set button to current state

function Instrument:update_scale_controls()
  TRACE("Instrument:update_scale_controls()")

  local instr = rns.selected_instrument
  local scale_mode = instr.trigger_options.scale_mode
  local scale_idx = xScale.get_scale_index_by_name(scale_mode)

  local ctrl = self._controls.prev_scale
  if ctrl then
    if (scale_idx == 1) then
      ctrl:set(self.palette.scale_prev_disabled)
    else
      ctrl:set(self.palette.scale_prev_enabled)
    end
  end

  local ctrl = self._controls.next_scale
  if ctrl then
    if (scale_idx == #xScale.SCALES) then
      ctrl:set(self.palette.scale_next_disabled)
    else
      ctrl:set(self.palette.scale_next_enabled)
    end
  end

  local ctrl = self._controls.set_key
  if ctrl then
    local palette = {}
    palette.tip = table.rcopy(self.palette.key_select_enabled)
    palette.tip.text = Instrument.SCALE_KEYS[instr.trigger_options.scale_key]
    palette.track = table.rcopy(self.palette.key_select_disabled)
    ctrl:set_palette(palette)
    ctrl:set_index(instr.trigger_options.scale_key)
  end



end

--- update display for prev/next instrument-navigation buttons

function Instrument:_update_instrument_controls()
  TRACE("Instrument:_update_instrument_controls()")

  local inst_idx = rns.selected_instrument_index

  local skip_event = true
  if self._inst_prev then
    if (inst_idx == 1) then
      self._inst_prev:set(self.palette.inst_prev_off)
    else
      self._inst_prev:set(self.palette.inst_prev_on)
    end
  end
  
  if self._inst_next then
    if (rns.instruments[inst_idx+1]) then
      self._inst_next:set(self.palette.inst_next_on)
    else
      self._inst_next:set(self.palette.inst_next_off)
    end
  end

end

--- update display for prev/next sample modulation set

function Instrument:_update_modset_controls()
  TRACE("Instrument:_update_modset_controls()")

  local inst = rns.selected_instrument
  local modset_idx = rns.selected_sample_modulation_set_index

  local skip_event = true
  if self._modset_prev then
    if (modset_idx == 1 or modset_idx == 0) then
      self._modset_prev:set(self.palette.modset_prev_off)
    else
      self._modset_prev:set(self.palette.modset_prev_on)
    end
  end
  
  if self._modset_next then
    if (inst.sample_modulation_sets[modset_idx+1]) then
      self._modset_next:set(self.palette.modset_next_on)
    else
      self._modset_next:set(self.palette.modset_next_off)
    end
  end

end

--- update display for prev/next sample device chain

function Instrument:_update_chain_controls()
  TRACE("Instrument:_update_chain_controls()")

  local inst = rns.selected_instrument
  local chain_idx = rns.selected_sample_device_chain_index

  local skip_event = true
  if self._chain_prev then
    if (chain_idx == 1 or chain_idx == 0) then
      self._chain_prev:set(self.palette.chain_prev_off)
    else
      self._chain_prev:set(self.palette.chain_prev_on)
    end
  end
  
  if self._chain_next then
    if (inst.sample_device_chains[chain_idx+1]) then
      self._chain_next:set(self.palette.chain_next_on)
    else
      self._chain_next:set(self.palette.chain_next_off)
    end
  end

end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.on_new_document

function Instrument:on_new_document()
  self:_attach_to_song()
end

--------------------------------------------------------------------------------

--- attach notifier to the song, handle changes

function Instrument:_attach_to_song()

  -- immediately attach to instrument 
  self:_attach_to_instrument()
  self:update_inst_name()
  self:update_chain_name()
  self:update_modset_name()
  
  -- follow active track in Renoise
  rns.selected_instrument_index_observable:add_notifier(
    function()
      self:_update_instrument_controls()
      self:update_inst_name()
      self:update_chain_name()
      self:_update_chain_controls()
    end
  )

  -- follow active sample fx chain
  rns.selected_sample_device_chain_observable:add_notifier(
    function()
      self:update_chain_name()
      self:_update_chain_controls()
    end
  )
  
  -- follow active sample modulation set
  rns.selected_sample_modulation_set_observable:add_notifier(
    function()
      self:update_modset_name()
      self:_update_modset_controls()
    end
  )

end

--------------------------------------------------------------------------------

--- attach notifier to the instrument

function Instrument:_attach_to_instrument()

  local instr = rns.selected_instrument

  -- update when selected scale changes
  instr.trigger_options.scale_mode_observable:add_notifier(
    function(notifier)
      --print("scale_mode_observable fired...")
      self:update_scale_controls()
    end
  )

  -- update when selected scale changes
  instr.trigger_options.scale_key_observable:add_notifier(
    function(notifier)
      --print("scale_key_observable fired...")
      self:update_scale_controls()
    end
  )

  instr.name_observable:add_notifier(
    function(notifier)
      self:update_inst_name()
    end
  )



end
