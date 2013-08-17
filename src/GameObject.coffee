# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.GameObject = class GameObject extends createjs.Bitmap
  isRemove: false
  
  constructor: (image, @game, @specs) ->
    @initialize image
    
    # TODO: perhaps use a vector2 class?
    @vel = {x: 0, y: 0}
    @accel = {x: 0, y: 0}
    
    @regX = @image.width * 0.5
    @regY = @image.height * 0.5
    
    @collideRect = {x: 0, y: 0, w: @image.width, h: @image.height}
    
    @specs or=
      accel: 100
      brake: 50
      vel: 100
      rotate: 50
    
  update: (delta) ->
    
  canCollide: (other) ->
    false
    
  collide: (other) ->
    
  @collideRect: (obj1, obj2) ->
    return not (obj1.x + obj1.collideRect.x + obj1.collideRect.w < obj2.x + obj2.collideRect.x or
                obj1.x + obj1.collideRect.x > obj2.x + obj2.collideRect.x + obj2.collideRect.w or
                obj1.y + obj1.collideRect.y + obj1.collideRect.h < obj2.y + obj2.collideRect.y or
                obj1.y + obj1.collideRect.y > obj2.y + obj2.collideRect.y + obj2.collideRect.h)
