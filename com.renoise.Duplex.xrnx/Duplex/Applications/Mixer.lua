--[[============================================================================
-- Duplex.Application.Mixer
============================================================================]]--

--[[--

Use the Mixer for controlling the Renoise mixer

#

[View the README.md](https://github.com/renoise/xrnx/blob/master/Tools/com.renoise.Duplex.xrnx/Docs/Applications/Mixer.md) (github)

--]]

--==============================================================================

-- constants

local MODE_PREFX = 1
local MODE_POSTFX = 2
local MODE_PREPOSTSYNC_ON = 1
local MODE_PREPOSTSYNC_OFF = 2
local MUTE_MODE_OFF = 1
local MUTE_MODE_MUTE = 2
local FOLLOW_TRACK_ON = 1
local FOLLOW_TRACK_OFF = 2
local TRACK_PAGE_AUTO = 1
local TAKE_OVER_VOLUME_OFF = 1
local TAKE_OVER_VOLUME_ON = 2

--==============================================================================

class 'Mixer' (Automateable)

Mixer.default_options = {
  pre_post = {
    label = "Pre/Post mode",
    description = "Change if either Pre or Post FX volume/pan is controlled",
    on_change = function(inst)
      inst._postfx_mode = (inst.options.pre_post.value==MODE_POSTFX) and 
        true or false
      inst._update_requested = true
    end,
    items = {
      "Pre FX volume and panning",
      "Post FX volume and panning",
    },
    value = 1,
  },
  mute_mode = {
    label = "Mute mode",
    description = "Decide if pressing mute will MUTE or OFF the track",
    items = {
      "Use OFF",
      "Use MUTE",
    },
    value = 1,
  },
  follow_track = {
    label = "Follow track",
    description = "Align with the selected track in Renoise",
    on_change = function(inst)
      inst:_follow_track()
    end,
    items = {
      "Follow track enabled",
      "Follow track disabled"
    },
    value = 1,
  },
  page_size = {
    label = "Page size",
    description = "Specify the step size when using paged navigation",
    on_change = function(inst)
      inst:_attach_to_tracks()
    end,
    items = {
      "Automatic: use available width",
      "1","2","3","4",
      "5","6","7","8",
      "9","10","11","12",
      "13","14","15","16",
    },
    value = 1,
  },
  take_over_volumes = {
    label = "Soft takeover",
    description = "Enables soft take-over for volume: useful if device-faders" 
                .."\nare not motorized. This feature will not take care of the"
                .."\nposition of the fader until the volume value is reached."
                .."\nExample: you are playing a song A and you finish it by"
                .."\nfading out the master volume. When you load a song B, the"
                .."\nmaster volume will not jump to 0 when you move the fader",
    items = {
      "Disabled",
      "Enabled",
    },
    value = 1,
  },


}

-- add Renoise 2.7+ specific options
if (renoise.API_VERSION >=2) then
  Mixer.default_options["sync_pre_post"] = {
    label = "Pre/Post sync",
    description = "Decide if switching Pre/Post is reflected "
              .."\nboth in Renoise and on the controller",
    items = {
      "Pre/Post sync is enabled",
      "Pre/Post sync is disabled",
    },
    value = 1,
  }
end

Mixer.available_mappings = {
  master = {
    description = "Mixer: Master volume",
  },
  fine = {
    description = "Mixer: Fine-control toggle"
  },
  levels = {
    description = "Mixer: Track volume",
    distributable = true,
    greedy = true,
  },
  panning = {
    description = "Mixer: Track panning",
    distributable = true,
    greedy = true,
  },
  mute = {
    description = "Mixer: Mute track",
    distributable = true,
    greedy = true,
  },
  solo = {
    description = "Mixer: Solo track",
    greedy = true,
  },
  next_page = {
    description = "Mixer: Next track page",
  },
  prev_page = {
    description = "Mixer: Previous track page",
  },
  mode = {
    description = "Mixer: Pre/Post FX mode",
  },
  labels = {
     description = "Mixer: Track label",
     distributable = true,
     greedy = true,
  },
  level_labels = {
     description = "Mixer: Level label",
     distributable = true,
     greedy = true,
  },
  pan_labels = {
     description = "Mixer: Pan label",
     distributable = true,
     greedy = true,
  },
  
}

Mixer.default_palette = {
  background        = { color={0x00,0x00,0x00}, val = false,text="??",},
  -- normal tracks
  normal_tip = {        color={0x00,0xff,0xff}, val = true, },
  normal_tip_dimmed = { color={0x00,0x40,0xff}, val = true, },
  normal_lane       = { color={0x00,0x81,0xff}, val = true, },
  normal_lane_dimmed = {color={0x00,0x40,0xff}, val = true, },
  normal_mute_on    = { color={0x40,0xff,0x40}, val = true, text ="M"},
  normal_mute_off   = { color={0x00,0x00,0x00}, val = false,text ="M",},
  -- master track
  master_tip        = { color={0xff,0xff,0xff}, val = true, },
  master_lane       = { color={0x80,0x80,0xff}, val = true, },
  master_mute_on    = { color={0xff,0xff,0x40}, val = true, text ="M",},
  -- send tracks
  send_tip          = { color={0xff,0x40,0x00}, val = true, },
  send_tip_dimmed   = { color={0x40,0x00,0xff}, val = true, },
  send_lane         = { color={0x81,0x00,0xff}, val = true, },
  send_lane_dimmed  = { color={0x40,0x00,0xff}, val = true, },
  send_mute_on      = { color={0xff,0x40,0x00}, val = true, text = "M", },
  send_mute_off     = { color={0x00,0x00,0x00}, val = false,text = "M", },
  -- pre/post buttons
  mixer_mode_pre    = { color={0xff,0xff,0xff}, val = true, text = "Pre",},
  mixer_mode_post   = { color={0x00,0x00,0x00}, val = false,text = "Post",},
  -- solo buttons
  solo_on           = { color={0xff,0x40,0x00}, val = true, text = "S",},
  solo_off          = { color={0x00,0x00,0x00}, val = false,text = "S", },
  -- prev/next page buttons
  prev_page_on      = { color={0xff,0xff,0xff}, val = true, text = "???",},
  prev_page_off     = { color={0x00,0x00,0x00}, val = false,text = "???",},
  next_page_on      = { color={0xff,0xff,0xff}, val = true, text = "???",},
  next_page_off     = { color={0x00,0x00,0x00}, val = false,text = "???",},
  -- Fine-control buttons
  fine_on           = { color={0xff,0xff,0xff}, val = true, text = "Fine",},
  fine_off          = { color={0x00,0x00,0x00}, val = false,text = "Fine", },
}

--------------------------------------------------------------------------------
--  merge superclass options, mappings & palette --

for k,v in pairs(Automateable.default_options) do
  Mixer.default_options[k] = v
end
for k,v in pairs(Automateable.available_mappings) do
  Mixer.available_mappings[k] = v
end
for k,v in pairs(Automateable.default_palette) do
  Mixer.default_palette[k] = v
end

--------------------------------------------------------------------------------
--- Constructor method
-- @param (VarArg)
-- @see Duplex.Application

function Mixer:__init(...)
  TRACE("Mixer:__init",...)

  -- the various controls
  self._controls = {}
  --  self._controls.master = nil
  --  self._controls.volume = nil
  --  self._controls.panning = nil
  --  self._controls.mutes = nil
  --  self._controls.solos = nil
  --  self._controls.pre_post_mode = nil

  -- the observed width of the mixer, and the step size for
  -- scrolling tracks (the value is derived from one of the
  -- available mappings: volume, mute, solo and panning)
  self._width = 0

  -- offset of the track, as controlled by the track navigator
  self._track_offset = nil

  -- (int), the total number of track pages
  self._page_count = nil

  -- (int), the current track page
  self._track_page = nil

  -- current track properties we are listening to
  self._attached_track_observables = table.create()

  self._update_requested = false


  -- list of takeover volumes
  self._take_over_volumes = {}

  -- apply arguments
  Automateable.__init(self,...)

  -- toggle, which defines if we're controlling the pre or post fx vol/pans
  self._postfx_mode = (self.options.pre_post.value == MODE_POSTFX)

  -- Fine accel multiplier
  self._fine_accel = 1

  --self:list_mappings_and_options(Mixer)

end


--------------------------------------------------------------------------------
-- @see Duplex.Automateable.on_idle

function Mixer:on_idle()

  if (not self.active) then 
    return 
  end
  if(self._update_requested) then
    self._update_requested = false
    self:_attach_to_tracks()
    self:update()
  end

  Automateable.on_idle(self)

end


--------------------------------------------------------------------------------

-- volume level changed from Renoise

function Mixer:set_track_volume(control_index, value)
  TRACE("Mixer:set_track_volume", control_index, value)

  if not self.active then
    return
  end

  local skip_event = true

  if (self._controls.volume ~= nil) then

    -- update track control
    self._controls.volume[control_index]:set_value(value, skip_event)
    
    -- reset the takeover hook (when not recording, as automation recording  
    -- output a stream of new values, and we would get caught in a "reset-loop")
    if not self._record_mode then
      if self._take_over_volumes[control_index] then
        self._take_over_volumes[control_index].hook = true
      end
    end

    -- update the master as well, if it has its own UI representation
    if (self._controls.master ~= nil) and 
       (control_index + self._track_offset == xTrack.get_master_track_index()) 
    then
      self._controls.master:set_value(value, skip_event)
    end
  end
  

end


--------------------------------------------------------------------------------

-- panning changed from Renoise

function Mixer:set_track_panning(control_index, value, skip_event_handler)
  TRACE("Mixer:set_track_panning", control_index, value, skip_event_handler)

  if (not skip_event_handler) then
    skip_event_handler = true
  end
  if (self.active and self._controls.panning ~= nil) then
    self._controls.panning[control_index]:set_value(value, skip_event_handler)
  end
end


--------------------------------------------------------------------------------

-- mute state changed from Renoise

function Mixer:set_track_mute(control_index, state)
  TRACE("Mixer:set_track_mute", control_index, state)

  if (self.active and self._controls.mutes ~= nil) then
    local muted = (state == renoise.Track.MUTE_STATE_ACTIVE)
    local master_track_index = xTrack.get_master_track_index()
    local track_index = self._track_offset+control_index
    local button = self._controls.mutes[control_index]
    if (track_index > master_track_index) then
      if muted then
        button:set(self.palette.send_mute_on)
      else
        button:set(self.palette.send_mute_off)
      end
    elseif (track_index == master_track_index) then
      button:set(self.palette.master_mute_on)
    else
      if muted then
        button:set(self.palette.normal_mute_on)
      else
        button:set(self.palette.normal_mute_off)
      end
    end
  end
end


--------------------------------------------------------------------------------

-- solo state changed from Renoise

function Mixer:set_track_solo(control_index, state, skip_event_handler)
  TRACE("Mixer:set_track_solo", control_index, state, skip_event_handler)

  if (not skip_event_handler) then
    skip_event_handler = true
  end
  if (self.active and self._controls.solos ~= nil) then
    if state then
      self._controls.solos[control_index]:set(self.palette.solo_on)
    else
      self._controls.solos[control_index]:set(self.palette.solo_off)
    end
  end
end

--------------------------------------------------------------------------------

-- solo state changed from Renoise

function Mixer:set_track_label(control_index, state)
   
   TRACE("Mixer:set_track_label", control_index, state)

   if (self.active and self._controls.labels ~= nil) then
      self._controls.labels[control_index]:set_text(state)
   end
end

--------------------------------------------------------------------------------

-- level state changed from Renoise

function Mixer:set_level_label(control_index, state)
   
   TRACE("Mixer:set_level_label", control_index, state)

   if (self.active and self._controls.level_labels ~= nil) then
      self._controls.level_labels[control_index]:set_text(state)
   end
end

--------------------------------------------------------------------------------

-- level state changed from Renoise

function Mixer:set_pan_label(control_index, state)
   
   TRACE("Mixer:set_pan_label", control_index, state)

   if (self.active and self._controls.pan_labels ~= nil) then
      self._controls.pan_labels[control_index]:set_text(state)
   end
end
--------------------------------------------------------------------------------

-- set dimmed state of slider - will only happen when:
-- - the controller has a color display
-- - when the control is unsolo'ed or unmuted

function Mixer:set_dimmed(control_index)
  TRACE("Mixer:set_dimmed()",control_index)

  local track_index = self._track_offset + control_index
  local track = rns.tracks[track_index]
  if (track) then

    local any_solo = xTrack.any_track_is_soloed()
    local is_send_track = (track_index > rns.sequencer_track_count + 1)
    local is_master_track = (track_index == rns.sequencer_track_count + 1)
    local dimmed = false

    if any_solo then
      dimmed = (not track.solo_state)
    else
      dimmed = (track.mute_state~=renoise.Track.MUTE_STATE_ACTIVE)
    end

    local monochrome = is_monochrome(self.display.device.colorspace)
    if not monochrome then
      if self._controls.volume and 
        self._controls.volume[control_index] 
      then
        local palette = nil

        if is_send_track then 
          if dimmed then
            palette = {
              tip = self.palette.send_tip_dimmed,
              track = self.palette.send_lane_dimmed,
            }
          else
            palette = {
              tip = self.palette.send_tip,
              track = self.palette.send_lane,
            }
          end
        elseif is_master_track then
          -- do nothing
        else
          if dimmed then
            palette = {
              tip = self.palette.normal_tip_dimmed,
              track = self.palette.normal_lane_dimmed,
            }
          else
            palette = {
              tip = self.palette.normal_tip,
              track = self.palette.normal_lane,
            }
          end

        end
        
        if palette then
          self._controls.volume[control_index]:set_palette(palette)
        end

      end
      --[[
      if self._controls.panning and 
        self._controls.panning[control_index] 
      then
        self._controls.panning[control_index]:set_dimmed(dimmed)
      end
      ]]
    end

  end

end

--------------------------------------------------------------------------------

-- update: set all controls to current values from renoise

function Mixer:update()  
  TRACE("Mixer:update()")

  if (not self.active) then
    return false
  end

  local skip_event = true
  local master_track_index = xTrack.get_master_track_index()
  local tracks = rns.tracks

  -- track volume/panning/mute and solo
  for control_index = 1,self._width do
  
    local track_index   = self._track_offset+control_index
    local track         = tracks[track_index]
    local track_type    = xTrack.determine_track_type(track_index)
    local valid_level   = (self._controls.volume  and 
      (control_index<=#self._controls.volume))
    local valid_mute    = (self._controls.mutes   and 
      (control_index<=#self._controls.mutes))
    local valid_solo    = (self._controls.solos   and 
      (control_index<=#self._controls.solos))
    local valid_panning = (self._controls.panning and 
      (control_index<=#self._controls.panning))
    local valid_label = (self._controls.labels and 
      (control_index<=#self._controls.labels))
    local valid_level_label = (self._controls.level_labels and 
      (control_index<=#self._controls.level_labels))
    local valid_pan_label = (self._controls.pan_labels and 
      (control_index<=#self._controls.pan_labels))
    
    -- assign values
    if (track_index <= #tracks) then
      
      if valid_level then
        local value = (self._postfx_mode) and
          track.postfx_volume.value or track.prefx_volume.value
        self:set_track_volume(control_index, value)
      end

      if valid_panning then
        local value = (self._postfx_mode) and 
          track.postfx_panning.value or track.prefx_panning.value
        self:set_track_panning(control_index, value)
      end

      if valid_mute then
        local mute_state = (track_index == master_track_index) and
          renoise.Track.MUTE_STATE_ACTIVE or track.mute_state
        self:set_track_mute(control_index, mute_state)
      end

      if valid_solo then
        self:set_track_solo(control_index, track.solo_state)
      end

      if valid_label then
         self:set_track_label(control_index, track.name)
      end
      
      if valid_level_label then
        local value = (self._postfx_mode) and
          track.postfx_volume.value_string or track.prefx_volume.value_string
        self:set_level_label(control_index, value)
      end

      if valid_pan_label then
        local value = (self._postfx_mode) and 
          track.postfx_panning.value_string or track.prefx_panning.value_string
        self:set_pan_label(control_index, value)
      end

    else
      -- deactivate, reset controls which have no track
      self:set_track_volume(control_index, 0)
      self:set_track_panning(control_index, 0)
      self:set_track_mute(control_index, renoise.Track.MUTE_STATE_OFF)
      self:set_track_solo(control_index, false)
      self:set_track_label(control_index, "")
      self:set_level_label(control_index, "")
      self:set_pan_label(control_index, "")

    end

    -- update the visual appearance 
    self:set_dimmed(control_index)

  end

  -- master volume
  if (self._controls.master ~= nil) then
     if (self._postfx_mode) then
       self._controls.master:set_value(xTrack.get_master_track().postfx_volume.value)
     else
       self._controls.master:set_value(xTrack.get_master_track().prefx_volume.value)
     end
  end
  
  if self._controls.prev_page then
    if (self._track_page > 0) then
      self._controls.prev_page:set(self.palette.prev_page_on)
    else
      self._controls.prev_page:set(self.palette.prev_page_off)
    end
  end
  if self._controls.next_page then
    if (self._track_page < self._page_count) then
      self._controls.next_page:set(self.palette.next_page_on)
    else
      self._controls.next_page:set(self.palette.next_page_off)
    end
  end

  -- mode controls
  if (self._controls.pre_post_mode) then
    if self._postfx_mode then
      self._controls.pre_post_mode:set(self.palette.mixer_mode_post)
    else
      self._controls.pre_post_mode:set(self.palette.mixer_mode_pre)
    end
  end

-- fine controls
  if self._controls.fine then
    if (self._fine_accel == 1) then
      self._controls.fine:set(self.palette.fine_off)
    else
      self._controls.fine:set(self.palette.fine_on)
    end
  end

end

--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.start_app
-- @return bool or nil

function Mixer:start_app()
  TRACE("Mixer.start_app()")

  if not Application.start_app(self) then
    return
  end

  self:_attach_to_song()
  self:update()

end


--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application.on_new_document

function Mixer:on_new_document()
  TRACE("Mixer:on_new_document")
  
  self:_attach_to_song()
  
  if (self.active) then
    self:update()
  end

  self:_init_take_over_volume()
end


--------------------------------------------------------------------------------

--- inherited from Application
-- @see Duplex.Application._build_app
-- @return bool

function Mixer:_build_app()
  TRACE("Mixer:_build_app(")

  local volume_group = nil
  local volume_count = nil

  local mutes_group = nil
  local mutes_count = nil

  local pannings_group = nil
  local pannings_count = nil

  local solos_count = nil

  local labels_group = nil
  local labels_count = nil
  
  local level_labels_group = nil
  local level_labels_count = nil
  
  local pan_labels_group = nil
  local pan_labels_count = nil

  local volume_size = nil
  local master_size = nil
  local grid_w = nil
  local grid_h = nil

  local cm = self.display.device.control_map

  -- check if the control-map describes a grid controller
  local slider_grid_mode = cm:is_grid_group(self.mappings.levels.group_name)
  
  --TRACE("Mixer:slider_grid_mode",slider_grid_mode)

  local embed_mutes = slider_grid_mode and (self.mappings.mute.group_name == 
    self.mappings.levels.group_name)
  local embed_solos = (self.mappings.solo.group_name == 
    self.mappings.levels.group_name)
  local embed_master = (self.mappings.master.group_name == 
                        self.mappings.levels.group_name)
  local embed_labels = (self.mappings.labels.group_name ==
                        self.mappings.labels)
  local embed_level_labels = (self.mappings.level_labels.group_name ==
                        self.mappings.level_labels)
  local embed_pan_labels = (self.mappings.pan_labels.group_name ==
                        self.mappings.pan_labels)

  -- determine the size of each group of controls
  volume_group = cm:get_params(self.mappings.levels.group_name,self.mappings.levels.index)

  if volume_group then
    if slider_grid_mode then
      grid_w,grid_h = cm:get_group_dimensions(self.mappings.levels.group_name)
      volume_count = (embed_master) and grid_w-1 or grid_w
      volume_size = grid_h
    else
      volume_count = #volume_group
      volume_size = 1
    end
  end

  pannings_group = 
    cm:get_params(self.mappings.panning.group_name,self.mappings.panning.index)

  if pannings_group then
    pannings_count = #pannings_group
  end

  local group = cm.groups[self.mappings.solo.group_name]
  if group then
    if slider_grid_mode then
      if embed_solos then
        solos_count = (embed_master) and grid_w-1 or grid_w
      else
        solos_count = volume_count
      end
    else
      solos_count = #group
    end
  end

  mutes_group = 
    cm:get_params(self.mappings.mute.group_name,self.mappings.mute.index)

  if mutes_group then
    if slider_grid_mode then
      if embed_mutes then
        mutes_count = (embed_master) and grid_w-1 or grid_w
      else
        mutes_count = volume_count
      end
    else
      mutes_count = #mutes_group
    end
  end

  labels_group =
  cm:get_params(self.mappings.labels.group_name,self.mappings.labels.index)

  if labels_group then
     labels_count = 8
        labels_count = #labels_group
  end
  
  level_labels_group =
  cm:get_params(self.mappings.level_labels.group_name,self.mappings.level_labels.index)

  if level_labels_group then
     level_labels_count = 8
        level_labels_count = #level_labels_group
  end
  
  pan_labels_group =
  cm:get_params(self.mappings.pan_labels.group_name,self.mappings.pan_labels.index)

  if pan_labels_group then
     pan_labels_count = 8
        pan_labels_count = #pan_labels_group
  end

  local group = cm.groups[self.mappings.master.group_name]
  if group then
    if slider_grid_mode then
      if embed_master then
        master_size = volume_size
      else
        master_size = #group
      end
    else
      master_size = 1
    end
  end

  -- set the overall mixer size from our groups
  self._width = 0
  if volume_count then
    self._width = volume_count
  elseif mutes_count then
    self._width = mutes_count
  elseif solos_count then
    self._width = solos_count
  elseif pannings_count then
     self._width = pannings_count
  elseif labels_count then
     self._width = labels_count
  elseif level_labels_count then
     self._width = level_labels_count
  elseif pan_labels_count then
     self._width = pan_labels_count
  end

  -- confirm that the various groups have the same size
  local identical_size = true
  if volume_count and not (self._width==volume_count) then
    identical_size = false
    TRACE("Mixer:volume_count has wrong size",self._width,volume_count)
  end
  if mutes_count and not (self._width==mutes_count) then
    identical_size = false
    TRACE("Mixer:mutes_count has wrong size",self._width,mutes_count)
  end
  if pannings_count and not (self._width==pannings_count) then
    identical_size = false
    TRACE("Mixer:pannings_count has wrong size",self._width,pannings_count)
  end
  if solos_count and not (self._width==solos_count) then
    identical_size = false
    TRACE("Mixer:solos_count has wrong size",self._width,solos_count)
  end
  if labels_count and not (self._width==labels_count) then
    identical_size = false
    TRACE("Mixer:labels_count has wrong size",self._width,labels_count)
  end
  if level_labels_count and not (self._width==level_labels_count) then
    identical_size = false
    TRACE("Mixer:level_labels_count has wrong size",self._width,level_labels_count)
  end
  if pan_labels_count and not (self._width==pan_labels_count) then
    identical_size = false
    TRACE("Mixer:pan_labels_count has wrong size",self._width,pan_labels_count)
  end
  if not identical_size then
    local msg = "Could not start Duplex Mixer - mappings for volume, "
              .."mutes, solo and panning mappings need to be the same size"
    renoise.app():show_warning(msg)
    return false
  end

  -- create tables to hold the controls
  
  self._controls.volume = (self.mappings.levels.group_name) and {} or nil
  self._controls.panning = (self.mappings.panning.group_name) and {} or nil
  self._controls.mutes = (self.mappings.mute.group_name) and {} or nil
  self._controls.solos = (self.mappings.solo.group_name) and {} or nil
  self._controls.labels = (self.mappings.labels.group_name) and {} or nil
  self._controls.level_labels = (self.mappings.level_labels.group_name) and {} or nil
  self._controls.pan_labels = (self.mappings.pan_labels.group_name) and {} or nil

    -- volume --------------------------------------------

  if self._controls.volume then
    for control_index = 1,volume_count do
      local param = volume_group[control_index]
      local y_pos = (embed_mutes) and ((embed_solos) and 3 or 2) or 1
      local c = UISlider(self)
      c.group_name = param.xarg.group_name
      c.tooltip = self.mappings.levels.description
      if (slider_grid_mode) then
        c:set_pos(param.xarg.index,y_pos)
        c:set_orientation(ORIENTATION.VERTICAL)
      else
        c:set_pos(param.xarg.index)
      end
      c.toggleable = true
      --c.flipped = false
      c.ceiling = RENOISE_DECIBEL
      c.slider_acceleration = self._fine_accel
      c:set_size(volume_size-(y_pos-1))
      c.on_change = function(obj) 

        --print("*** self._controls.volume.on_change - obj.value",obj.value)
        
        local track_index = self._track_offset + control_index
        obj.slider_acceleration = self._fine_accel

        if (track_index == xTrack.get_master_track_index()) then
          if (self._controls.master) then
            -- update separate master level
            self._controls.master:set_value(obj.value,true)
          end
        elseif (track_index > #rns.tracks) then
          -- track is outside bounds
          return 
        end
        
        local track = rns.tracks[track_index]
        local volume = (self._postfx_mode) and 
          track.postfx_volume or track.prefx_volume
        
        self:_set_volume(volume,track_index,obj)
      
        if self._controls.level_labels then
          self:set_level_label(control_index,volume.value_string)
        end
        
      end

      --c.on_press = function(obj)
        -- define this, or button mode won't work
      --end
      
      self._controls.volume[control_index] = c

    end

  end
    


    -- panning -------------------------------------------

  if self._controls.panning then
    for control_index = 1,pannings_count do
      local param = pannings_group[control_index]
      local c = UISlider(self)
      c.group_name = param.xarg.group_name
      c.tooltip = self.mappings.panning.description
      c:set_pos(param.xarg.index)
      c.toggleable = true
      --c.flipped = false
      c.ceiling = 1.0
      c:set_size(1)
      c:set_orientation(ORIENTATION.VERTICAL)
      c.slider_acceleration = self._fine_accel
      
      -- slider changed from controller
      c.on_change = function(obj) 
        obj.slider_acceleration = self._fine_accel

        --print("*** panning changed from controller - obj.value",obj.value)
        
        local track_index = self._track_offset + control_index

        if (track_index > #rns.tracks) then
          -- track is outside bounds
          return 

        else

          local track = rns.tracks[track_index]
          local panning = (self._postfx_mode) and 
            track.postfx_panning or track.prefx_panning
          panning.value = obj.value
          if self._record_mode then
            self.automation:record(track_index,panning,obj.value)
          end
          
          if self._controls.pan_labels then
            self:set_pan_label(control_index,panning.value_string)
          end

        end
      end
      
      self._controls.panning[control_index] = c

    end
  end
        

    -- mute buttons -----------------------------------

    local precheck = function(track_index)

    end
    
  if self._controls.mutes then
    for control_index = 1,mutes_count do
      TRACE("Mixer:adding mute#",control_index)
      local param = mutes_group[control_index]
      local c = UIButton(self)
      c.group_name = param.xarg.group_name
      c.tooltip = self.mappings.mute.description
      c:set_pos(param.xarg.index)

      -- value changed via button
      c.on_press = function(obj) 
        local track_index = self._track_offset + control_index

        --print("on_press")

        if (track_index == xTrack.get_master_track_index()) then
          -- can't mute the master track
          return 
        elseif (track_index > #rns.tracks) then
          -- track is outside bounds
          return 
        end
        
        local track = rns.tracks[track_index]
        local track_is_muted = (track.mute_state ~= renoise.Track.MUTE_STATE_ACTIVE)

        if (track_is_muted) then
          track:unmute()
        else 
          track:mute()
          local mute_state = (self.options.mute_mode.value==MUTE_MODE_MUTE)
            and renoise.Track.MUTE_STATE_MUTED or renoise.Track.MUTE_STATE_OFF
          track.mute_state = mute_state
        end

        self:set_dimmed(control_index)

      end

      -- value changed via slider
      c.on_change = function(obj,val)
        local track_index = self._track_offset + control_index

        if (track_index == xTrack.get_master_track_index()) then
          -- can't mute the master track
          return 
        elseif (track_index > #rns.tracks) then
          -- track is outside bounds
          return 
        end
  
        -- turn on if more than midways
        local ceiling = 127 -- todo !!!
        local track_is_muted = (val > ceiling/2)
        local track = rns.tracks[track_index]

        if (track_is_muted) then
          track:unmute()
        else 
          track:mute()
          local mute_state = (self.options.mute_mode.value==MUTE_MODE_MUTE)
            and renoise.Track.MUTE_STATE_MUTED or renoise.Track.MUTE_STATE_OFF
          track.mute_state = mute_state
        end

        self:set_dimmed(control_index)

      end

      -- secondary feature: hold mute button to solo track
      --[[
      c.on_hold = function(obj)

        local track_index = self._track_offset + control_index

        if (track_index > #rns.tracks) then
          -- track is outside bounds
          return false
        end
        
        local track = rns.tracks[track_index]
        track.solo_state = not track.solo_state

      end
      ]]
      
      self._controls.mutes[control_index] = c    

    end
  end

  -- solo buttons -----------------------------------

  if self._controls.solos then
    for control_index = 1,solos_count do
      TRACE("Mixer:adding solo#",control_index)
      local c = UIButton(self)
      c.group_name = self.mappings.solo.group_name
      c.tooltip = self.mappings.solo.description
      if embed_solos then
        local y_pos = (embed_mutes) and 2 or 1
        c:set_pos(control_index,y_pos)
      else
        c:set_pos(control_index)
      end

      -- mute state changed from controller
      -- (update the slider.dimmed property)
      c.on_press = function(obj) 

        local track_index = self._track_offset + control_index
        if (track_index > #rns.tracks) then
          -- track is outside bounds
          return 
        end
        
        local track = rns.tracks[track_index]
        track.solo_state = not track.solo_state

      end
      
      self._controls.solos[control_index] = c    

    end

  end
    

  -- labels -----------------------------------

  if self._controls.labels then
    for control_index = 1,labels_count do
      TRACE("Mixer:adding label#",control_index)
      local c = UILabel(self)
      c.group_name = self.mappings.labels.group_name
      c.tooltip = self.mappings.labels.description
      c:set_pos(control_index)

      self._controls.labels[control_index] = c 

    end

  end

  -- level labels -----------------------------------

  if self._controls.level_labels then
    for control_index = 1,level_labels_count do
      TRACE("Mixer:adding level label#",control_index)
      local c = UILabel(self)
      c.group_name = self.mappings.level_labels.group_name
      c.tooltip = self.mappings.level_labels.description
      c:set_pos(control_index)

      self._controls.level_labels[control_index] = c 

    end

  end
  
  -- pan labels -----------------------------------

  if self._controls.pan_labels then
    for control_index = 1,pan_labels_count do
      TRACE("Mixer:adding level label#",control_index)
      local c = UILabel(self)
      c.group_name = self.mappings.pan_labels.group_name
      c.tooltip = self.mappings.pan_labels.description
      c:set_pos(control_index)

      self._controls.pan_labels[control_index] = c 

    end

  end
  
  -- master fader ------------------------------

  if (self.mappings.master.group_name) then
    TRACE("Mixer:adding master")
    local master_pos = self.mappings.master.index or 1
    local c = UISlider(self)
    c.group_name = self.mappings.master.group_name
    c.tooltip = self.mappings.master.description
    c:set_pos((embed_master) and (volume_count + 1) or master_pos)
    c.toggleable = true
    c.ceiling = RENOISE_DECIBEL
    c:set_size(master_size)
    c:set_orientation(ORIENTATION.VERTICAL)
    c:set_palette({
      tip=self.palette.master_tip,
      track=self.palette.master_lane,
    })
    c.on_change = function(obj) 
      --print("*** master.on_change",obj.value)
      local track_index = xTrack.get_master_track_index()
      local control_index = track_index - self._track_offset
      if (self._controls.volume and 
          control_index > 0 and 
          control_index <= volume_count) 
      then
        -- update visible master level slider
        self._controls.volume[control_index]:set_value(obj.value,true)
      end
      local track = xTrack.get_master_track()

      local volume = (self._postfx_mode) and 
        track.postfx_volume or track.prefx_volume

      self:_set_volume(volume,track_index,obj)
        
    end 
    c.on_press = function(obj)
      -- this needs to be defined, or button mode won't work
    end

    self._controls.master = c

  end
  

  local map = self.mappings.prev_page
  if map.group_name then
    local c = UIButton(self)
    c.group_name = map.group_name
    c:set_pos(map.index or 1)
    c.tooltip = map.description
    c.on_press = function()
      if (self._track_page>0) then
        self:_set_track_page(self._track_page-1)
      end
    end
    self._controls.prev_page = c
  end

  local map = self.mappings.next_page
  if map.group_name then
    local c = UIButton(self)
    c.group_name = map.group_name
    c:set_pos(map.index or 1)
    c.tooltip = map.description
    c.on_press = function()
      if (self._track_page<self._page_count) then
        self:_set_track_page(self._track_page+1)
      end
    end
    self._controls.next_page = c
  end


  -- Pre/Post FX mode ---------------------------

  if (self.mappings.mode.group_name) then
    TRACE("Mixer:adding Pre/Post FX mode")
    local c = UIButton(self)
    c.group_name = self.mappings.mode.group_name
    c.tooltip = self.mappings.mode.description
    c:set_pos(self.mappings.mode.index or 1)

    -- mode state changed from controller
    c.on_press = function(obj) 
      
      self._postfx_mode = not self._postfx_mode
      self._update_requested = true
      self:_init_take_over_volume()

      if self.options.sync_pre_post and
        (self.options.sync_pre_post.value == MODE_PREPOSTSYNC_ON) 
      then
        renoise.app().window.mixer_view_post_fx = self._postfx_mode
        end


    end
    
    self._controls.pre_post_mode = c

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
    self._controls.fine = c
  end
    
  Automateable._build_app(self)
  return true

end

--------------------------------------------------------------------------------

-- set volume with support for automation recording and soft takeover
-- @return bool (true when volume has been set)

function Mixer:_set_volume(parameter,track_index,obj)
  TRACE("Mixer:_set_volume()",parameter,track_index,obj)

  local value_set = false
  if self.options.take_over_volumes.value == TAKE_OVER_VOLUME_ON then
    value_set = self:_set_take_over_volume(parameter, obj, track_index)
  else
    parameter.value = obj.value
    value_set = true
  end
  if value_set and self._record_mode then
    -- scale back value to 0-1 range
    self.automation:record(track_index,parameter,obj.value/RENOISE_DECIBEL)
  end

  return value_set

end


--------------------------------------------------------------------------------
-- adds notifiers to song
-- invoked when a new document becomes available
-- @see Duplex.Automateable._attach_to_song

function Mixer:_attach_to_song()
  TRACE("Mixer:_attach_to_song")

  rns = renoise.song()

  -- initialize important parameters
  local track_idx = rns.selected_track_index 
  self._track_page = self:_get_track_page(track_idx)
  self:_update_page_count()
  self._track_offset = 0  

  -- attach to mixer PRE/POST 
  if (renoise.API_VERSION >=2) then
    renoise.app().window.mixer_view_post_fx_observable:add_notifier(
      function()
        TRACE("Mixer:mixer_view_post_fx_observable fired...")
        if (self.options.sync_pre_post.value == MODE_PREPOSTSYNC_ON) then
          self._postfx_mode = renoise.app().window.mixer_view_post_fx
          self._update_requested = true
        end
      end
    )
  end

  -- update on track changes in the song
  rns.tracks_observable:add_notifier(
    function()
      TRACE("Mixer:tracks_changed fired...")
      self._update_requested = true
    end
  )

  -- and immediately attach to the current track set
  local new_song = true
  self:_attach_to_tracks(new_song)

  -- follow active track in Renoise
  rns.selected_track_index_observable:add_notifier(
    function()
      TRACE("Mixer:selected_track_observable fired...")
      self:_follow_track()
    end
  )
  self:_follow_track()

  Automateable._attach_to_song(self)

  

end


--------------------------------------------------------------------------------

-- when following the active track in Renoise, we call this method

function Mixer:_follow_track()
  TRACE("Mixer:_follow_track()")

  if (self.options.follow_track.value == FOLLOW_TRACK_OFF) then
    return
  end

  local track_idx = rns.selected_track_index 
  local page = self:_get_track_page(track_idx)
  if (page~=self._track_page) then
    self._track_page = page
    self._track_offset = page*self:_get_page_width()
    self._update_requested = true
    self:_init_take_over_volume()

  end

end

--------------------------------------------------------------------------------

-- figure out the active "track page" based on the supplied track index
-- @param track_idx (int), renoise track number
-- return integer (0-number of pages)

function Mixer:_get_track_page(track_idx)
  TRACE("Mixer:_get_track_page()",track_idx)

  local page_width = self:_get_page_width()
  return math.floor((track_idx-1)/page_width)

end


--------------------------------------------------------------------------------

--- paged navigation: if follow track is enabled, this will set the active
-- track - otherwise, only the track offset is updated
-- @param page_idx (int)

function Mixer:_set_track_page(page_idx)
  TRACE("Mixer:_set_track_page()",page_idx)

  local page_width = self:_get_page_width()

  if (self.options.follow_track.value == FOLLOW_TRACK_ON) then
    local offset = (rns.selected_track_index%page_width)
    local num_tracks = #rns.tracks
    local track_idx = (page_idx * page_width) + offset  
    rns.selected_track_index = math.min(num_tracks,track_idx)
  else
    self._track_offset = (page_idx * page_width)
    self._update_requested = true
    self:_init_take_over_volume()
  end

end

--------------------------------------------------------------------------------

function Mixer:_set_fine(accel)
  TRACE("Mixer:_set_fine()",accel)

  self._fine_accel = accel
  self._update_requested = true
end

--------------------------------------------------------------------------------

function Mixer:_get_page_width()
  TRACE("Mixer:_get_page_width()")

  return (self.options.page_size.value==TRACK_PAGE_AUTO)
    and self._width or self.options.page_size.value-1

end


--------------------------------------------------------------------------------

function Mixer:_update_page_count()

  local page_width = self:_get_page_width()
  self._page_count = math.floor((#rns.tracks-1)/page_width)

end

--------------------------------------------------------------------------------

-- add notifiers to parameters
-- invoked when tracks are added/removed/swapped

function Mixer:_attach_to_tracks(new_song)
  TRACE("Mixer:_attach_to_tracks", new_song)

  local tracks = rns.tracks

  -- validate and update the sequence/track offset
  --[[
  if (self._page_control) then
    local page_width = self:_get_page_width()
    local pages = math.floor((#rns.tracks-1)/page_width)
    self._page_control:set_range(nil,math.max(0,pages))
  end
  ]]
    
  -- detach all previously added notifiers first
  -- but don't even try to detach when a new song arrived. old observables
  -- will no longer be alive then...
  if (not new_song) then
    for _,observable in pairs(self._attached_track_observables) do
      -- temp security hack. can also happen when removing tracks
      pcall(function() observable:remove_notifier(self) end)
    end
  end
  
  self._attached_track_observables:clear()
  
  
  -- attach to the new ones in the order we want them
  local master_idx = xTrack.get_master_track_index()
  local master_done = false
  
  -- track volume level 
  if self._controls.volume then
    for control_index = 1,math.min(#tracks, #self._controls.volume) do
      local track_index = self._track_offset + control_index
      local track = tracks[track_index]
      if not track then
        break
      end
      local volume = (self._postfx_mode) and 
        track.postfx_volume or track.prefx_volume
      self._attached_track_observables:insert(
        volume.value_observable)
      volume.value_observable:add_notifier(
        self, 
        function()
          if (self.active) then
            local value = volume.value
            local value_string = volume.value_string
            -- compensate for potential loss of precision 
            if not 
              cLib.float_compare(self._controls.volume[control_index].value, value, 1000) 
            then
              self:set_track_volume(control_index, value)
              if self._controls.level_labels then
                self:set_level_label(control_index, value_string)
              end
            end
          end
        end
      )
      if (track_index == master_idx) then
        master_done = true
      end
    end
  end

  -- track panning 
  if self._controls.panning then
    for control_index = 1,math.min(#tracks, #self._controls.panning) do
      local track_index = self._track_offset + control_index
      local track = tracks[track_index]
      if not track then
        break
      end
      local panning = (self._postfx_mode) and 
         track.postfx_panning or track.prefx_panning
      
      self._attached_track_observables:insert(
        panning.value_observable)

      panning.value_observable:add_notifier(
        self, 
        function()
          if (self.active) then
            local value = panning.value
            local value_string = panning.value_string
            -- compensate for potential loss of precision 
            if not 
              cLib.float_compare(self._controls.panning[control_index].value, value, 1000) 
            then
              self:set_track_panning(control_index, value)
              if self._controls.pan_labels then
                self:set_pan_label(control_index, value_string)
              end
            end
          end
        end 
      )
    end
  end

  -- track mute-state 
  if self._controls.mutes then
    for control_index = 1,math.min(#tracks, #self._controls.mutes) do
      local track_index = self._track_offset + control_index
      local track = tracks[track_index]
      if not track then
        break
      end
      self._attached_track_observables:insert(track.mute_state_observable)
      track.mute_state_observable:add_notifier(
        self, 
        function()
          if (self.active) then
            self:set_track_mute(control_index, track.mute_state)
          end
        end 
      )
    end
  end

  -- track solo-state 
  if self._controls.solos then
    for control_index = 1,math.min(#tracks, #self._controls.solos) do
      local track_index = self._track_offset + control_index
      local track = tracks[track_index]
      if not track then
        break
      end
      self._attached_track_observables:insert(track.solo_state_observable)
      track.solo_state_observable:add_notifier(
        self, 
        function()
          if (self.active) then
            self:set_track_solo(control_index, track.solo_state)
            self._update_requested = true

          end
        end 
      )
    end
  end

  -- track solo-state 
  if self._controls.labels then
    for control_index = 1,math.min(#tracks, #self._controls.labels) do
      local track_index = self._track_offset + control_index
      local track = tracks[track_index]
      if not track then
        break
      end
      self:set_track_label(control_index, track.name)
    end
  end
  
  -- if master wasn't already mapped just before
  if (not master_done and self._controls.master) then
    local track = rns.tracks[master_idx]
    local volume = (self._postfx_mode) and 
      track.postfx_volume or track.prefx_volume

    self._attached_track_observables:insert(
      volume.value_observable)
  
    volume.value_observable:add_notifier(
      self, 
      function()
        if (self.active) then
          local value = volume.value
          -- compensate for potential loss of precision 
          if not cLib.float_compare(self._controls.master.value, value, 1000) then
            self._controls.master:set_value(value)
          end
        end
      end 
    )
  end

end

-- Sets the volume of a track when a Controller's fader hooks the actual
-- volume of the track.
-- @param p_volume (DeviceParameter)
-- @param p_obj (UIComponent) the control that contain the value
-- @param p_track_index (int) look for / remember by this index 
-- @return (bool) true when value was set
function Mixer:_set_take_over_volume(p_volume, p_obj, p_track_index)
  TRACE("Mixer:_set_take_over_volume()",p_volume, p_obj, p_track_index)

  local p_from_master = (p_track_index == xTrack.get_master_track_index())

  -- If a fader is not registered into the table, we init it
  if not self._take_over_volumes[p_track_index] then
    self._take_over_volumes[p_track_index] = {hook = true, last_value = nil}
  end

  local take_over = self._take_over_volumes[p_track_index]
  local value_set = false

  -- Master volume can be controlled by 2 sliders at the same time.
  -- Need to determinated if the hook system must be reset depending on which
  -- fader control it.
  if p_from_master ~= nil then
    if take_over.master_move ~= p_from_master then
      take_over.hook = true
      take_over.last_value = p_obj.value
    end
    take_over.master_move = p_from_master
  end
      
  -- If hook is activated, fader will have no effect on track volume
  if take_over.hook then
    if not take_over.last_value then
      take_over.last_value = p_obj.value
    end

    -- determines if fader has reached/crossed the track volume
    -- first, see if the volume is within threshold ("sticky")
    local reached = cLib.float_compare(p_volume.value,p_obj.value,5)
    if not reached then
      local x1 = p_volume.value - take_over.last_value 
      local x2 = p_volume.value - p_obj.value
      reached = (cLib.sign(x1) ~= cLib.sign(x2))
    end
    
    if reached then 
      p_volume.value = p_obj.value
      take_over.hook = false
      value_set = true
    end
  else
    -- hook is deactivated, Mixer reacts normally
    p_volume.value = p_obj.value
    take_over.last_value = p_obj.value
    --print("change take-over to this value",p_track_index,p_obj.value)
    value_set = true
  end

  --rprint(self._take_over_volumes)
  return value_set

end

-- Init (or re-init) hook system. For instance, when a new song is loaded or
-- when user moves among tracks.
function Mixer:_init_take_over_volume()
  TRACE("Mixer:_init_take_over_volume()")
  for _, v in pairs(self._take_over_volumes) do 
    v.hook = true
    v.last_value = nil
  end
end
