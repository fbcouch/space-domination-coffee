# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}
# imports
GameObject = window.SpaceDom.GameObject
Ship = window.SpaceDom.Ship

window.SpaceDom.SpaceDominationGame = class SpaceDominationGame
  gameObjects: []
  
  constructor: (@stage, @canvas, @preload) ->
    @levelGroup = new createjs.Container()
    
    @backgroundGroup = new createjs.Container()
    @foregroupGroup = new createjs.Container()
    @gameObjGroup = new createjs.Container()
    
    @levelGroup.addChild @backgroundGroup
    @levelGroup.addChild @gameObjGroup
    @levelGroup.addChild @foregroundGroup
    
    @stage.addChild @levelGroup
    
    @player = new Ship @preload.getResult('base-fighter1'), this
    @player.x = @canvas.width / 4
    @player.y = (@canvas.height - @player.image.height) / 2
    
    @addObject @player
    
    testEnemy = new Ship @preload.getResult('base-enemy1'), this
    testEnemy.x = @canvas.width * 3/4
    testEnemy.y = @player.y
    
    @addObject testEnemy
    
  update: (delta, keys) ->
    
    if keys.left and not keys.right
      @player.rotation -= @player.specs.rotate * delta
    else if keys.right and not keys.left
      @player.rotation += @player.specs.rotate * delta
    
    if keys.accel and not keys.brake
      @player.accel.x = @player.specs.accel * Math.cos @player.rotation * Math.PI / 180
      @player.accel.y = @player.specs.accel * Math.sin @player.rotation * Math.PI / 180
    else if keys.brake and not keys.accel and (@player.vel.x isnt 0 or @player.vel.y isnt 0)
      angle = Math.atan2 @player.vel.y, @player.vel.x
      @player.accel.x = -1 * @player.specs.brake * Math.cos angle
      @player.accel.y = -1 * @player.specs.brake * Math.sin angle
    else
      @player.accel.x = @player.accel.y = 0
      
      # prevent acceleration backwards
      if Math.abs(@player.accel.x * delta) >= Math.abs(@player.vel.x)
        @player.accel.x = @player.vel.x = 0
      if Math.abs(@player.accel.y * delta) >= Math.abs(@player.vel.y)
        @player.accel.y = @player.vel.y = 0 
    
    @player.fire() if keys.fire
    
    for obj in @gameObjects
      obj.vel.x += obj.accel.x * delta
      obj.vel.y += obj.accel.y * delta
      
      # clamp velocity to max
      if obj.specs.vel * obj.specs.vel < obj.vel.x * obj.vel.x + obj.vel.y * obj.vel.y
        angle = Math.atan2 obj.vel.y, obj.vel.x
        obj.vel.x = obj.specs.vel * Math.cos angle
        obj.vel.y = obj.specs.vel * Math.sin angle
      
      obj.x += obj.vel.x * delta
      obj.y += obj.vel.y * delta
      
      obj.update delta
      
      for other in @gameObjects[@gameObjects.indexOf(obj)+1..]
        if obj.canCollide?(other) and other.canCollide?(obj) and GameObject.collideRect(obj, other) and ndgmr.checkPixelCollision(obj, other, 0, false)
          console.log 'collide!'
          obj.collide other
          other.collide obj
      
    @removeObject(obj) for obj in @gameObjects when obj?.isRemove
    
    # center display on player
    @levelGroup.x = @canvas.width * 0.5 - @player.x
    @levelGroup.y = @canvas.height * 0.5 - @player.y
    
  addObject: (obj) ->
    @gameObjects.push obj if obj not in @gameObjects
    @gameObjGroup.addChild obj
    
  removeObject: (obj) ->
    @gameObjects.splice(@gameObjects.indexOf(obj), 1) if obj in @gameObjects
    @gameObjGroup.removeChild obj
