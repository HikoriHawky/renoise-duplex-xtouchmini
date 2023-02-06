-- Duplex.X-Touch-Mini

duplex_configurations:insert {

   -- configuration properties
   name = "6. Sampler FX",
   pinned = true,

   -- device properties
   device = {
      display_name = "X-Touch Mini",
      class_name = "XTouchMini",
      device_port_in = "X-TOUCH MINI",
      device_port_out = "X-TOUCH MINI",
      control_map ="Controllers/X-Touch-Mini/Controlmaps/X-Touch-Mini_6_SamplerFX.xml",
      --thumbnail = "X-Touch-Mini.bmp",
      protocol = DEVICE_PROTOCOL.MIDI
   },

   applications = {
      EffectSampler = {
         mappings = {
            parameters = {
               group_name = "Encoders",
            },
            param_names = {
               group_name = "LabelsA",
            },
            param_values = {
              group_name = "LabelsB",
            },
            device_prev = {
               group_name = "Buttons1",
               index = 1,
            },
            device_next = {
               group_name = "Buttons1",
               index = 2,
            },
            device_select = {
              group_name = "EncodersAlt",
              index = 8,
            },
            param_prev = {
               group_name = "Buttons1",
               index = 7,
            },
            param_next = {
               group_name = "Buttons1",
               index = 8,
            },
            device_name = {
              group_name = "MasterLabel",
              index = 3,
            },
            ext_editor = {
              group_name = "Buttons1",
              index = 3,
            },
            fine = {
              group_name = "Buttons2",
              index = 1,
            },
            bank_name = {
              group_name = "MasterLabel",
              index = 4,
            },
            bank_prev = {
               group_name = "Buttons1",
               index = 5,
            },
            bank_next = {
               group_name = "Buttons1",
               index = 6,
            },
         },
         palette = {
           -- param page buttons
           prev_param_on      = { color={0xff,0xff,0xff}, val = true, text = "Pg. ◄",},
           prev_param_off     = { color={0x00,0x00,0x00}, val = false,text = "Pg. ◄",},
           next_param_on      = { color={0xff,0xff,0xff}, val = true, text = "Pg. ►",},
           next_param_off     = { color={0x00,0x00,0x00}, val = false,text = "Pg. ►",},
           -- preset page buttons
           prev_preset_on      = { color={0xff,0xff,0xff}, val = true, text = "Pst. ◄",},
           prev_preset_off     = { color={0x00,0x00,0x00}, val = false,text = "Pst. ◄",},
           next_preset_on      = { color={0xff,0xff,0xff}, val = true, text = "Pst. ►",},
           next_preset_off     = { color={0x00,0x00,0x00}, val = false,text = "Pst. ►",},
           -- device buttons
           prev_device_on      = { color={0xff,0xff,0xff}, val = true, text = "Dev. ◄",},
           prev_device_off     = { color={0x00,0x00,0x00}, val = false,text = "Dev. ◄",},
           next_device_on      = { color={0xff,0xff,0xff}, val = true, text = "Dev. ►",},
           next_device_off     = { color={0x00,0x00,0x00}, val = false,text = "Dev. ►",},
         },
         options = {
            include_parameters = 4,
         },
      },
      Mixer = {
        mappings = {
          master = {
            group_name = "Master",
            index = 1,
          },
        },
        options = {
          pre_post = 2,
          take_over_volumes = 2,
        },
      },
      Transport = {
         mappings = {
            start_playback = {
               group_name = "Buttons2",
               index = 7,
            },
            stop_playback = {
               group_name = "Buttons2",
               index = 6,
            },
            loop_pattern = {
              group_name = "Buttons2",
              index = 5,
            },
            edit_mode = {
              group_name = "Buttons2",
              index = 8
            },
         },
      },
      Instrument = {
        mappings = {
          chain_name = {
            group_name = "MasterLabel",
            index = 1,
          },
          chain_prev = {
            group_name = "Buttons2",
            index = 3,
          },
          chain_next = {
            group_name = "Buttons2",
            index = 4,
          },
        },
      },
      SwitchConfiguration = {
        mappings = {
          goto_next = {
            group_name = "Layers",
            index = 2,
          },
          goto_previous = {
            group_name = "Layers",
            index = 1,
          },
        },
      },
   },
}
               
