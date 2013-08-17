# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.SpaceDominationGame = class SpaceDominationGame
  constructor: (@stage, @canvas, @preload) ->
    
    @player = new createjs.Bitmap @preload.getResult('base-fighter1')
    @player.x = @canvas.width / 4
    @player.y = (@canvas.height - @player.image.height) / 2
    
    @stage.addChild @player
    
    @testEnemy = new createjs.Bitmap @preload.getResult('base-enemy1')
    @testEnemy.x = @canvas.width * 3/4
    @testEnemy.y = @player.y + 25
    
    @stage.addChild @testEnemy
    
    
    
  update: (delta, keys) ->
    
    @player.x += 10 if keys.accel and not keys.brake