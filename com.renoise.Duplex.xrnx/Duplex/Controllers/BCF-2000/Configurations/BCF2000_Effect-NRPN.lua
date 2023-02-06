--[[----------------------------------------------------------------------------
-- Duplex.BCF2000
----------------------------------------------------------------------------]]--

duplex_configurations:insert {

  -- configuration properties
  name = "Effect (NRPN)",
  pinned = true,

  -- device properties
  device = {
    class_name = "BCF2000",          
    display_name = "BCF-2000",
    device_port_in = "BCF2000",
    device_port_out = "BCF2000",
    control_map = "Controllers/BCF-2000/Controlmaps/BCF-2000_Effect-NRPN.xml",
    thumbnail = "Controllers/BCF-2000/BCF-2000.bmp",
    protocol = DEVICE_PROTOCOL.MIDI
  },
  
  applications = {
    Mixer = {
      mappings = {
        panning = {
          group_name= "Encoders1",
        },
        levels = {
          group_name = "Encoders2",
        },
        mode = {
          group_name = "DialPush4",
          index = 6,
        },
      },
      options = {
        follow_track = 1,
      }
    },
    TrackSelector = {
      mappings = {
        select_track = {
          group_name = "DialPush2",
        },
        prev_page = {
          group_name = "ControlButtonRow1",
          index = 1,
        },
        next_page = {
          group_name = "ControlButtonRow1",
          index = 2,
        },

      },
    },
    Effect = {
      mappings = {
        parameters = {
          group_name= "Faders",
        },
        device = {
          group_name= "Buttons1",
        },
        param_prev = {
          group_name = "ControlButtonRow2",
          index = 1,
        },
        param_next = {
          group_name = "ControlButtonRow2",
          index = 2,
        },
      },
    },
    Transport = {
      mappings = {
        start_playback = {
          group_name = "DialPush1",
          index = 1,
        },
        stop_playback = {
          group_name = "DialPush1",
          index = 2,
        },
        loop_pattern = {
          group_name = "DialPush1",
          index = 3,
        },
        goto_previous = {
          group_name = "DialPush1",
          index = 4,
        },
        goto_next = {
          group_name = "DialPush1",
          index = 5,
        },
        edit_mode = {
          group_name = "DialPush1",
          index = 6,
        },
        follow_player = {
          group_name = "DialPush1",
          index = 7,
        },
        metronome_toggle = {
          group_name = "DialPush1",
          index = 8,
        },
      },
      options = {
      }
    },

    SwitchConfiguration = {
      mappings = {
        goto_previous = {
          group_name = "DialPush4",
          index = 7,
        },
        goto_next = {
          group_name = "DialPush4",
          index = 8,
        },
      }
    },
  }
}



