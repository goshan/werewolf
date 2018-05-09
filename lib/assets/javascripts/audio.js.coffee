@Wolf = @Wolf ? {}

class @Wolf.Audio
  constructor: ->
    @preload_progress = 0
    @audio_sum = 30

    ion.sound {
      sounds: [
        { name: "mute" },
        { name: "night_bgm", volume: 2 },
        { name: "night_start_voice" },
        { name: "augur_bgm", volume: 0.3, loop: true },
        { name: "augur_start_voice" },
        { name: "augur_end_voice" },
        { name: "wolf_bgm", volume: 0.4, loop: true },
        { name: "wolf_start_voice" },
        { name: "wolf_end_voice" },
        { name: "long_wolf_bgm", volume: 0.3, loop: true },
        { name: "long_wolf_start_voice" },
        { name: "long_wolf_end_voice" },
        { name: "witch_bgm", volume: 0.3, loop: true },
        { name: "witch_start_voice" },
        { name: "witch_end_voice" },
        { name: "magician_bgm", volume: 0.5, loop: true },
        { name: "magician_start_voice" },
        { name: "magician_end_voice" },
        { name: "seer_bgm", volume: 0.5, loop: true },
        { name: "seer_start_voice" },
        { name: "seer_end_voice" },
        { name: "savior_bgm", volume: 0.5, loop: true },
        { name: "savior_start_voice" },
        { name: "savior_end_voice" },
        { name: "day_bgm", volume: 0.3 },
        { name: "day_start_voice" },
        { name: "over_bgm", volume: 0.3 },
        { name: "over_wolf_lose" },
        { name: "over_wolf_win" },
        { name: "over_over" }
      ],

      path: "/audio/",
      preload: true,
      multiplay: true,
      volume: 1.0,

      ready_callback: (obj) =>
        @preload_progress += 100/@audio_sum
        $('.progress .progress-bar').css('width', "#{@preload_progress}%")

      ended_callback: (obj) ->
        res = obj.name.match /(.+)_end_voice/
        if res && res[0] == obj.name
          setTimeout ->
            ion.sound.stop "#{res[1]}_bgm"
          , 1000
    }

  play_audio: (type) ->
    if type == 'wolf_lose' || type == "wolf_win" || type == "over"
      ion.sound.play 'over_bgm'
      setTimeout ->
        ion.sound.play "over_#{type}"
      , 1000
    else
      res = type.match /(.+)_(.+)/
      if res && res[0] == type
        if res[2] == "start"
          ion.sound.play "#{res[1]}_bgm"
          setTimeout ->
            ion.sound.play "#{res[0]}_voice"
          , 1000
        else if res[2] == "end"
          setTimeout ->
            ion.sound.play "#{res[0]}_voice"
          , 4000
 
