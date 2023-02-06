--[[----------------------------------------------------------------------------
-- Duplex.R-control
   ----------------------------------------------------------------------------]]--

--[[

   Inheritance: X-Touch Mini > MidiDevice > Device

   A device-specific class
   
--]]

class "XTouchMini" (MidiDevice)

function XTouchMini:__init(display_name, message_stream, port_in, port_out)
  TRACE("XTouchMini:__init", display_name, message_stream, port_in, port_out)

  MidiDevice.__init(self, display_name, message_stream, port_in, port_out)

  self.allow_zero_velocity_note_on = true

end

--------------------------------------------------------------------------------

-- override default MidiDevice method
-- Knob LEDs: 0 - single, 1 - boost/cut, 2 - wrap, 3 - spread


function XTouchMini:send_cc_message(number,value,channel,multibyte,param)
  TRACE("XTouchMini:send_cc_message()",number,value,channel,multibyte,param)

  if not channel then
    channel = self.default_midi_channel
  end

  local msg_channel = 0xAF+channel
  local msg_number = math.floor(number)

  if 16 <= msg_number and msg_number <= 23 then
    local led_mode = param.xarg.led_mode
    local led_number = number + 32
    if not led_mode then
      led_mode = 2
    end
    local message = {msg_channel, led_number, bit.lshift(led_mode,4) + math.max(1,math.floor(1 + value * 11 / 127))}
    self:send_midi(message)
  else
    local message = {msg_channel, msg_number, math.floor(value)}
    self:send_midi(message)
  end

  if 16 <= msg_number and msg_number <= 23 then
    local led_mode = param.xarg.led_mode
    local led_number = number + 32
    if not led_mode then
      led_mode = 2
    end
    local message = {msg_channel, led_number, bit.lshift(led_mode,4) + math.max(1,math.floor(1 + value * 11 / 127))}
    self:send_midi(message)
  end
end
