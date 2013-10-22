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
    localStorage['pilots'] or= '{}'
    JSON.parse localStorage['pilots']

  savePilots: (pilots) ->
    localStorage['pilots'] = JSON.stringify pilots

  loadPilot: (pilot_id) ->
    JSON.parse(localStorage['pilots'])['pilot_id']

  savePilot: (pilot_id, data) ->
    pilot_list = @listPilots()
    pilot_list[pilot_id] = data
    @savePilots pilot_list
