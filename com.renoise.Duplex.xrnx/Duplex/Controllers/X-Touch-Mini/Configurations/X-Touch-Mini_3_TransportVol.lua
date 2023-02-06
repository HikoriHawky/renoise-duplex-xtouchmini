-- Duplex.X-Touch-Mini

duplex_configurations:insert {

   -- configuration properties
   name = "3. Transport + Volume",
   pinned = true,

   -- device properties
   device = {
     display_name = "X-Touch Mini",
     class_name = "XTouchMini",
     device_port_in = "X-TOUCH MINI",
     device_port_out = "X-TOUCH MINI",
     control_map ="Controllers/X-Touch-Mini/Controlmaps/X-Touch-Mini_3_TransportVol.xml",
     --thumbnail = "X-Touch-Mini.bmp",
     protocol = DEVICE_PROTOCOL.MIDI
   },

   applications = {
      Mixer_1 = {
        application = "Mixer",
         mappings = {
            levels = {
               group_name = "Encoders",
            },
            labels = {
               group_name = "LabelsA",
            },
            level_labels = {
              group_name = "LabelsB",
            },
            prev_page = {
               group_name = "Buttons1",
               index = 1,
            },
            next_page = {
               group_name = "Buttons1",
               index = 2,
            },
            master = {
               group_name = "Master",
            },
            fine = {
              group_name = "Buttons2",
              index = 1,
            },
         },
         palette = {
           -- prev/next page buttons
           prev_page_on      = { color={0xff,0xff,0xff}, val = true, text = "Pg. ◄",},
           prev_page_off     = { color={0x00,0x00,0x00}, val = false,text = "Pg. ◄",},
           next_page_on      = { color={0xff,0xff,0xff}, val = true, text = "Pg. ►",},
           next_page_off     = { color={0x00,0x00,0x00}, val = false,text = "Pg. ►",},
         },
         options = {
           page_size = 9,
           pre_post = 2,
           follow_track = 1,
           take_over_volumes = 1,
         },
      },
      Transport_1 = {
        application = "Transport",
         mappings = {
            start_playback = {
               group_name = "Buttons2",
               index = 7,
            },
            stop_playback = {
               group_name = "Buttons2",
               index = 6,
            },
            edit_mode = {
               group_name = "Buttons2",
               index = 8,
            },
            loop_pattern = {
               group_name = "Buttons2",
               index = 5,
            },
            goto_previous = {
              group_name = "Buttons2",
              index = 3,
            },
            goto_next = {
              group_name = "Buttons2",
              index = 4,
            },
            block_loop = {
              group_name = "Buttons1",
              index = 3,
            },
            metronome_toggle = {
              group_name = "Buttons2",
              index = 2,
            },
            follow_player = {
              group_name = "Buttons1",
              index = 4,
            },
            songpos_display = {
              group_name = "MasterLabel",
              index = 1,
            },
         },
         options = {
           pattern_stop = 2,
           jump_mode = 2,
         },
      },
      Navigator = {
        mappings = {
          blockpos = {
            group_name = "Navigator",
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
   }
}
               
