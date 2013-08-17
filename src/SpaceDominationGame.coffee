# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}
# imports
GameObject = window.SpaceDom.GameObject

window.SpaceDom.SpaceDominationGame = class SpaceDominationGame
  gameObjects: []
  
  constructor: (@stage, @canvas, @preload) ->
    
    @player = new GameObject @preload.getResult('base-fighter1'), this
    @player.x = @canvas.width / 4
    @player.y = (@canvas.height - @player.image.height) / 2
    
    @addObject @player
    
    testEnemy = new GameObject @preload.getResult('base-enemy1'), this
    testEnemy.x = @canvas.width * 3/4
    testEnemy.y = @player.y + 25
    
    @addObject testEnemy
    
  update: (delta, keys) ->
    
    if keys.left and not keys.right
      @player.rotation -= 50 * delta
    else if keys.right and not keys.left
      @player.rotation += 50 * delta
    
    if keys.accel and not keys.brake
      @player.accel.x = 100 * Math.cos @player.rotation * Math.PI / 180
      @player.accel.y = 100 * Math.sin @player.rotation * Math.PI / 180
    else if keys.brake and not keys.accel and (@player.vel.x isnt 0 or @player.vel.y isnt 0)
      angle = Math.atan2 @player.vel.y, @player.vel.x
      @player.accel.x = -100 * Math.cos angle
      @player.accel.y = -100 * Math.sin angle
    else
      @player.accel.x = @player.accel.y = 0
      
      # prevent acceleration backwards
      if Math.abs(@player.accel.x * delta) >= Math.abs(@player.vel.x)
        @player.accel.x = @player.vel.x = 0
      if Math.abs(@player.accel.y * delta) >= Math.abs(@player.vel.y)
        @player.accel.y = @player.vel.y = 0 
    
    for obj in @gameObjects
      obj.vel.x += obj.accel.x * delta
      obj.vel.y += obj.accel.y * delta
      
      obj.x += obj.vel.x * delta
      obj.y += obj.vel.y * delta
      
    
  addObject: (obj) ->
    @gameObjects.push obj if obj not in @gameObjects
    @stage.addChild obj
    
  removeObject: (obj) ->
    @gameObjects.splice(@gameObjects.indexOf(obj), 1) if obj in @gameObjects
    @stage.removeChild obj
