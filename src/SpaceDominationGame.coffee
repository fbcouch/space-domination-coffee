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
    @screen = new SpaceDom.LevelScreen @preload, 'training-crates'
    @screen.show()
    @screen.resize @canvas.width, @canvas.height

    @stage.addChild @screen

  update: (delta, keys) ->
    @screen?.update? delta, keys

  resize: () ->
    @screen.resize @canvas.width, @canvas.height
