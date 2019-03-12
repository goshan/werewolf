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
        { name: "hidden_wolf_bgm", volume: 0.3, loop: true },
        { name: "hidden_wolf_start_voice" },
        { name: "hidden_wolf_end_voice" },
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
        { name: "mixed_bgm", volume: 0.5, loop: true },
        { name: "mixed_start_voice" },
        { name: "mixed_end_voice" },
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
        if obj.name == "night_bgm" || (res && res[0] == obj.name)
          setTimeout ->
            App.game.do 'next_turn'
            ion.sound.stop "#{res[1]}_bgm" if res && res[1]
          , 1000
    }

  play_audio: (type) ->
    stop_all = true
    if type == 'wolf_lose' || type == "wolf_win" || type == "over"
      bgm = "over_bgm"
      voice = "over_#{type}"
    else
      res = type.match /(.+)_(.+)/
      if res && res[0] == type
        if res[2] == "start"
          bgm = "#{res[1]}_bgm"
          voice = "#{res[0]}_voice"
        else if res[2] == "end"
          stop_all = false
          voice = "#{res[0]}_voice"
 
    ion.sound.stop() if stop_all

    if bgm && voice
      # start audio: new bgm and new voice
      # voice after bgm: 1s
      ion.sound.play bgm
      setTimeout ->
        ion.sound.play voice
      , 1000
    else if voice
      # end audio: new voice with current bgm
      # voice delay: 4s
      setTimeout ->
        ion.sound.play voice
      , 4000

