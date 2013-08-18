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
    # arbitrarily, we will transform obj2 onto obj1 then determine if it falls into obj1's collideRect
    
    obj2rect = [
      obj2.localToLocal(obj2.collideRect.x                     , obj2.collideRect.y                     , obj1),
      obj2.localToLocal(obj2.collideRect.x + obj2.collideRect.w, obj2.collideRect.y                     , obj1),
      obj2.localToLocal(obj2.collideRect.x                     , obj2.collideRect.y + obj2.collideRect.h, obj1),
      obj2.localToLocal(obj2.collideRect.x + obj2.collideRect.w, obj2.collideRect.y + obj2.collideRect.h, obj1)
    ]
    
    for point in obj2rect
      return true if obj1.collideRect.x <= point.x <= obj1.collideRect.x + obj1.collideRect.w and
                     obj1.collideRect.y <= point.y <= obj1.collideRect.x + obj1.collideRect.w
    return false
    
  @pixelCollide: (obj1, obj2) ->
    collideCanvas1 = document.createElement 'canvas'
    ctx1 = collideCanvas1.getContext '2d'
    
    collideCanvas2 = document.createElement 'canvas'
    ctx2 = collideCanvas2.getContext '2d'
    
    collideCanvas1.width = obj1.image.width
    collideCanvas1.height = obj1.image.height
    ctx1.drawImage obj1.image, 0, 0
    
    collideCanvas2.width = obj2.image.width
    collideCanvas2.height = obj2.image.height
    ctx2.drawImage obj2.image, 0, 0
    
    data1 = ctx1.getImageData(0, 0, obj1.image.width, obj1.image.height).data
    data2 = ctx2.getImageData(0, 0, obj2.image.width, obj2.image.height).data
    
    # for now, just check all obj2 against obj1
    for x in [obj2.collideRect.x..obj2.collideRect.x+obj2.collideRect.w]
      for y in [obj2.collideRect.y..obj2.collideRect.y+obj2.collideRect.h]
        point = obj2.localToLocal x, y, obj1
        if obj1.collideRect.x <= point.x <= obj1.collideRect.x + obj1.collideRect.w and
           obj1.collideRect.y <= point.y <= obj1.collideRect.y + obj1.collideRect.h and
           data1[parseInt(point.x) * parseInt(point.y) * 4 + 4] > 50 and data2[x * y * 4 + 4] > 50
          # uncomment this to draw debug circles
          #g = new createjs.Graphics()
          #pt = obj1.localToGlobal parseInt(point.x), parseInt(point.y)
          #g.beginFill(createjs.Graphics.getRGB(255, 0, 0)).drawCircle 0, 0, 1
          
          #s = new createjs.Shape(g)
          #s.x = pt.x
          #s.y = pt.y
          
          return true
    false
    