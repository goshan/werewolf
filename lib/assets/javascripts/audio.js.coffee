@Wolf = @Wolf ? {}

class @Wolf.Audio
  constructor: ->
    @preload_progress = 0
    @audio_sum = 30

    ion.sound {
      sounds: [
        {name: "mute"},
        {
          name: "night_bgm"
          volume: 2,
        },
        {
          name: "night_voice"
        },
        {
          name: "augur_bgm",
          volume: 0.3,
          loop: true
        },
        {
          name: "augur_start_voice"
        },
        {
          name: "augur_end_voice"
        },
        {
          name: "wolf_bgm",
          volume: 0.4,
          loop: true
        },
        {
          name: "wolf_start_voice"
        },
        {
          name: "wolf_end_voice"
        },
        {
          name: "long_wolf_bgm",
          volume: 0.3,
          loop: true
        },
        {
          name: "long_wolf_start_voice"
        },
        {
          name: "long_wolf_end_voice"
        },
        {
          name: "witch_bgm",
          volume: 0.3,
          loop: true
        },
        {
          name: "witch_start_voice"
        },
        {
          name: "witch_end_voice"
        },
        {
          name: "magician_bgm",
          volume: 0.5,
          loop: true
        },
        {
          name: "magician_start_voice"
        },
        {
          name: "magician_end_voice"
        },
        {
          name: "seer_bgm",
          volume: 0.5,
          loop: true
        },
        {
          name: "seer_start_voice"
        },
        {
          name: "seer_end_voice"
        },
        {
          name: "savior_bgm",
          volume: 0.5,
          loop: true
        },
        {
          name: "savior_start_voice"
        },
        {
          name: "savior_end_voice"
        },
        {
          name: "day_bgm",
          volume: 0.3
        },
        {
          name: "day_voice"
        },
        {
          name: "over_bgm",
          volume: 0.3
        },
        {name: "over_wolf_lose"},
        {name: "over_wolf_win"},
        {name: "over_voice"}
      ],

      path: "/audio/",
      preload: true,
      multiplay: true,
      volume: 1.0,

      ready_callback: (obj) =>
        @preload_progress += 100/@audio_sum
        $('.progress .progress-bar').css('width', "#{@preload_progress}%")

      ended_callback: (obj) ->
        if obj.name == 'wolf_end_voice'
          setTimeout ->
            ion.sound.stop 'wolf_bgm'
          , 1000
        else if obj.name == 'long_wolf_end_voice'
          setTimeout ->
            ion.sound.stop 'long_wolf_bgm'
          , 1000
        else if obj.name == 'witch_end_voice'
          setTimeout ->
            ion.sound.stop 'witch_bgm'
          , 1000
        else if obj.name == 'seer_end_voice'
          setTimeout ->
            ion.sound.stop 'seer_bgm'
          , 1000
        else if obj.name == 'savior_end_voice'
          setTimeout ->
            ion.sound.stop 'savior_bgm'
          , 1000
        else if obj.name == 'magician_end_voice'
          setTimeout ->
            ion.sound.stop 'magician_bgm'
          , 1000
        else if obj.name == 'augur_end_voice'
          setTimeout ->
            ion.sound.stop 'augur_bgm'
          , 1000
    }

  play_audio: (type) ->
    if type == 'night_start'  # 12069ms
      ion.sound.play 'night_bgm'
      setTimeout ->
        ion.sound.play 'night_voice'
      , 1000
    else if type == 'wolf_start'
      ion.sound.play 'wolf_bgm'
      setTimeout ->
        ion.sound.play 'wolf_start_voice'
      , 1000
    else if type == 'wolf_end'  # 7194ms
      setTimeout ->
        ion.sound.play 'wolf_end_voice'
      , 4000
    else if type == 'long_wolf_start'
      ion.sound.play 'long_wolf_bgm'
      setTimeout ->
        ion.sound.play 'long_wolf_start_voice'
      , 1000
    else if type == 'long_wolf_end'  # 6042ms
      setTimeout ->
        ion.sound.play 'long_wolf_end_voice'
      , 3000
    else if type == 'witch_start'
      ion.sound.play 'witch_bgm'
      setTimeout ->
        ion.sound.play 'witch_start_voice'
      , 1000
    else if type == 'witch_end'  # 6042ms
      setTimeout ->
        ion.sound.play 'witch_end_voice'
      , 3000
    else if type == 'seer_start'
      ion.sound.play 'seer_bgm'
      setTimeout ->
        ion.sound.play 'seer_start_voice'
      , 1000
    else if type == 'seer_end'  # 6216ms
      setTimeout ->
        ion.sound.play 'seer_end_voice'
      , 3000
    else if type == 'savior_start'
      ion.sound.play 'savior_bgm'
      setTimeout ->
        ion.sound.play 'savior_start_voice'
      , 1000
    else if type == 'savior_end'  # 6273
      setTimeout ->
        ion.sound.play 'savior_end_voice'
      , 3000
    else if type == 'magician_start'
      ion.sound.play 'magician_bgm'
      setTimeout ->
        ion.sound.play 'magician_start_voice'
      , 1000
    else if type == 'magician_end'
      setTimeout ->
        ion.sound.play 'magician_end_voice'
      , 3000
    else if type == 'augur_start'
      ion.sound.play 'augur_bgm'
      setTimeout ->
        ion.sound.play 'augur_start_voice'
      , 1000
    else if type == 'augur_end'
      setTimeout ->
        ion.sound.play 'augur_end_voice'
      , 3000
    else if type == 'day_start'
      ion.sound.play 'day_bgm'
      setTimeout ->
        ion.sound.play 'day_voice'
      , 1000
    else if type == 'wolf_lose'
      ion.sound.play 'over_bgm'
      setTimeout ->
        ion.sound.play 'over_wolf_lose'
      , 1000
    else if type == 'wolf_win'
      ion.sound.play 'over_bgm'
      setTimeout ->
        ion.sound.play 'over_wolf_win'
      , 1000
    else if type == 'over'
      ion.sound.play 'over_bgm'
      setTimeout ->
        ion.sound.play 'over_voice'
      , 1000

 
