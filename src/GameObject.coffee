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
    
  @pixelCollide: (obj1, obj2) ->
    
    obj1rect = [
      obj1.localToLocal(obj1.collideRect.x                     , obj1.collideRect.y                     , obj2),
      obj1.localToLocal(obj1.collideRect.x + obj1.collideRect.w, obj1.collideRect.y                     , obj2),
      obj1.localToLocal(obj1.collideRect.x                     , obj1.collideRect.y + obj1.collideRect.h, obj2),
      obj1.localToLocal(obj1.collideRect.x + obj1.collideRect.w, obj1.collideRect.y + obj1.collideRect.h, obj2),
    ]
    
    checkRect = {}
    for point in obj1rect
      checkRect.x1 = point.x if not checkRect.x1 or obj2.collideRect.x <= point.x <= checkRect.x1
      checkRect.x2 = point.x if not checkRect.x2 or checkRect.x2 <= point.x <= obj2.collideRect.x + obj2.collideRect.w
      checkRect.y1 = point.y if not checkRect.y1 or obj2.collideRect.y <= point.y <= checkRect.y1
      checkRect.y2 = point.y if not checkRect.y2 or checkRect.y2 <= point.y <= obj2.collideRect.y + obj2.collideRect.h 
    
    checkRect.x1 = obj2.collideRect.x if checkRect.x1 < obj2.collideRect.x or checkRect.x1 > checkRect.x2
    checkRect.x2 = obj2.collideRect.x + obj2.collideRect.w if checkRect.x2 > obj2.collideRect.x + obj2.collideRect.w or checkRect.x2 < checkRect.x1
    checkRect.y1 = obj2.collideRect.y if checkRect.y1 < obj2.collideRect.y or checkRect.y1 > checkRect.y2
    checkRect.y2 = obj2.collideRect.y + obj2.collideRect.h if checkRect.y2 > obj2.collideRect.y + obj2.collideRect.h or checkRect.y2 < checkRect.y1
    
    for x in [Math.round(checkRect.x1)..Math.round(checkRect.x2)]
      for y in [Math.round(checkRect.y1)..Math.round(checkRect.y2)]
        point = obj2.localToLocal x, y, obj1
        point.x = Math.round point.x
        point.y = Math.round point.y
        if obj1.collideRect.x <= point.x <= obj1.collideRect.x + obj1.collideRect.w and
           obj1.collideRect.y <= point.y <= obj1.collideRect.y + obj1.collideRect.h and
           obj1.hitTest(point.x, point.y) and obj2.hitTest(x, y)
          return true  
    false
    