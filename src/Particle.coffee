# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

GameObject = window.SpaceDom.GameObject

window.SpaceDom.Particle = class Particle extends createjs.Container

  constructor: (id, @game) ->
    proto = @game.preload.getResult('particles')[id]
    @initialize()
    data =
      images: (@game.preload.getResult image for image in proto.images)
      frames: proto.frames
      animations: proto.animations
    spriteSheet = new createjs.SpriteSheet(data)
    @animation = new createjs.Sprite(spriteSheet, "anim")
    @addChild @animation

  isComplete: ->
    @animation.paused