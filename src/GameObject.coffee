# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.GameObject = class GameObject extends createjs.Bitmap
  constructor: (image, @game) ->
    @initialize image
    
    # TODO: perhaps use a vector2 class?
    @vel = {x: 0, y: 0}
    @accel = {x: 0, y: 0}
    
    @regX = @image.width * 0.5
    @regY = @image.height * 0.5
    
    @collideRect = {x: 0, y: 0, w: @image.width, h: @image.height}
    
  update: (delta) ->
    
  canCollide: (other) ->
    false
    
  collide: (other) ->
    
