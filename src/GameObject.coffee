# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.GameObject = class GameObject extends createjs.Container
  isRemove: false
  hud: false
  
  constructor: (image, @game, specs) ->
    @initialize()

    @image = new createjs.Bitmap image
    @addChild @image
    @width = @image.image.width
    console.log @image
    @height = @image.image.height
    @regX = @width / 2
    @regY = @height / 2

    # TODO: perhaps use a vector2 class?
    @vel = {x: 0, y: 0}
    @accel = {x: 0, y: 0}
    
    @collideRect = {x: 0, y: 0, w: @width, h: @height}

    @specs =
      accel: 100
      brake: 50
      vel: 100
      rotate: 50

    @specs[key] = value for key, value of specs

  update: (delta) ->
    
  canCollide: (other) ->
    true
    
  collide: (other) ->
    
  @collideRect: (obj1, obj2) ->

    obj2rect = [
      obj2.localToLocal(obj2.collideRect.x                     , obj2.collideRect.y                     , obj1),
      obj2.localToLocal(obj2.collideRect.x + obj2.collideRect.w, obj2.collideRect.y                     , obj1),
      obj2.localToLocal(obj2.collideRect.x                     , obj2.collideRect.y + obj2.collideRect.h, obj1),
      obj2.localToLocal(obj2.collideRect.x + obj2.collideRect.w, obj2.collideRect.y + obj2.collideRect.h, obj1)
    ]
    
    for point in obj2rect
      return true if obj1.collideRect.x <= point.x <= obj1.collideRect.x + obj1.collideRect.w and
                     obj1.collideRect.y <= point.y <= obj1.collideRect.y + obj1.collideRect.h
                     
    obj1rect = [
      obj1.localToLocal(obj1.collideRect.x                     , obj1.collideRect.y                     , obj2),
      obj1.localToLocal(obj1.collideRect.x + obj1.collideRect.w, obj1.collideRect.y                     , obj2),
      obj1.localToLocal(obj1.collideRect.x                     , obj1.collideRect.y + obj1.collideRect.h, obj2),
      obj1.localToLocal(obj1.collideRect.x + obj1.collideRect.w, obj1.collideRect.y + obj1.collideRect.h, obj2),
    ]
    
    for point in obj1rect
      return true if obj2.collideRect.x <= point.x <= obj2.collideRect.x + obj2.collideRect.w and
                     obj2.collideRect.y <= point.y <= obj2.collideRect.y + obj2.collideRect.h
    
    return false