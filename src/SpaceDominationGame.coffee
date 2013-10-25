# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}
# imports
GameObject = window.SpaceDom.GameObject
Ship = window.SpaceDom.Ship
HUD = window.SpaceDom.HUD
Particle = window.SpaceDom.Particle

window.SpaceDom.SpaceDominationGame = class SpaceDominationGame

  constructor: (@stage, @canvas, @preload) ->
#    @setScreen(new SpaceDom.LevelScreen @preload, 'training-crates')
#    @setMenuScreen()
    @setScreen new SpaceDom.ProfileScreen @preload, @

  update: (delta, @keys) ->
    @screen?.update? delta, @keys

  resize: () ->
    @screen.resize @canvas.width / @screen.scaleX, @canvas.height / @screen.scaleY

  setScreen: (screen) ->
    if @screen?
      @screen.hide?()
      @stage.removeAllChildren()

    @screen = screen
    @resize @canvas.width, @canvas.height
    @screen.show()

    @stage.addChild @screen

  setMenuScreen: () ->
    @setScreen new SpaceDom.MissionSelectScreen @preload, @

  listPilots: () ->
    localStorage['pilots'] or= '[]'
    @profiles = JSON.parse localStorage['pilots']

  savePilots: (pilots, noreload) ->
    localStorage['pilots'] = JSON.stringify pilots
    @listPilots() if not noreload

  loadPilot: (pilot_id) ->
    @profile = JSON.parse(localStorage["pilots.#{pilot_id}"])

  savePilot: (pilot_id, data) ->
    if pilot_id not in @profiles
      @profiles.push pilot_id
      @savePilots @profiles
    localStorage["pilots.#{pilot_id}"] = JSON.stringify data

  processStats: (level, stats, victory) ->
    return if not @profile?

    @profile.stats or= {}
    @profile.stats.alltime or=
      kills: 0
      deaths: 0
      shots_fired: 0
      shots_hit: 0
      damage_dealt: 0
      damage_taken: 0
      victories: 0
      defeats: 0
    @profile.stats.missions or= {}
    @profile.stats.missions[level] or=
      kills: 0
      deaths: 0
      shots_fired: 0
      shots_hit: 0
      damage_dealt: 0
      damage_taken: 0
      victories: 0
      defeats: 0

    for key, val of stats
      @profile.stats.alltime[key] += val
      @profile.stats.missions[level][key] += val
      if victory
        @profile.stats.alltime.victories++
        @profile.stats.missions[level].victories++
      else
        @profile.stats.alltime.defeats++
        @profile.stats.missions[level].defeats++

    @savePilot @profile.name, @profile