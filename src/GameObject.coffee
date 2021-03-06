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

    @stats =
      shots_fired: 0
      shots_hit: 0
      damage_taken: 0
      damage_dealt: 0
      kills: 0
      deaths: 0

    @image = new createjs.Bitmap image
    @addChild @image
    @width = @image.image.width
    @height = @image.image.height
    @regX = @width / 2
    @regY = @height / 2

    # TODO: perhaps use a vector2 class?
    @vel = {x: 0, y: 0}
    @accel = {x: 0, y: 0}
    
    @collideRect = {x: 0, y: 0, w: @width, h: @height}

    @specs =
      accel: 0
      brake: 0
      vel: 0
      rotate: 0

    @specs[key] = value for key, value of specs

    @particle_timer = 0

  update: (delta) ->

    @particle_timer -= delta
    if @particle_timer <= 0 and (@accel.x isnt 0 or @accel.y isnt 0) and @engine?
      for point in @engine.points
        particle = new SpaceDom.Particle @engine.particle, @game
        offsetXY = { x: point.x - @regX, y: point.y - @regY }
        offset = { angle: 0, mag: 0 }
        offset.angle = Math.atan2 offsetXY.y, offsetXY.x
        offset.mag = Math.sqrt offsetXY.x * offsetXY.x + offsetXY.y * offsetXY.y
        angle = this.rotation * Math.PI / 180

        particle.x = @x + offset.mag * Math.cos offset.angle + angle
        particle.y = @y + offset.mag * Math.sin offset.angle + angle

        @game.addParticle particle
      @particle_timer = 0.1
    
  canCollide: (other) ->
    true
    
  collide: (other) ->

  thrust: (delta, brake) ->
    if brake
      angle = Math.atan2 @vel.y, @vel.x
      @accel.x = -1 * @specs.brake * Math.cos angle
      @accel.y = -1 * @specs.brake * Math.sin angle

      @accel.x = @vel.x = 0 if Math.abs(@accel.x * delta) >= Math.abs(@vel.x)
      @accel.y = @vel.y = 0 if Math.abs(@accel.y * delta) >= Math.abs(@vel.y)

    else
      @accel.x = @specs.accel * Math.cos @rotation * SpaceDom.DEG_TO_RAD
      @accel.y = @specs.accel * Math.sin @rotation * SpaceDom.DEG_TO_RAD

  rotate: (delta, left) ->
    @rotation += (if left then -1 else 1) * @specs.rotate * delta
    @rotation -= 360 if @rotation > 360
    @rotation += 360 if @rotation < 0
    
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