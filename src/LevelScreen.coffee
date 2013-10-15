# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.LevelScreen = class LevelScreen extends SpaceDom.Screen
  gameObjects: []
  particles: []

  constructor: (@preload, @game, level) ->
    super @preload, @game

    @level = @preload.getResult level
    @shiplist = @preload.getResult 'shiplist'

  show: () ->
    @levelGroup = new createjs.Container()

    @backgroundGroup = new createjs.Container()
    @foregroundGroup = new createjs.Container()
    @gameObjGroup = new createjs.Container()
    @HUD = new SpaceDom.HUD @

    @levelGroup.addChild @backgroundGroup
    @levelGroup.addChild @gameObjGroup
    @levelGroup.addChild @foregroundGroup
    @levelGroup.addChild @HUD

    @addChild @levelGroup

    @generateLevel()

  resize: (@width, @height) ->
    if @backgroundGroup?
      @backgroundGroup.removeAllChildren()
      @generateBackground()

  update: (delta, keys) ->
    super(delta, keys)

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
      continue if obj.isRemove
      for other in @gameObjects[@gameObjects.indexOf(obj)+1..] when not other.isRemove
        if obj.canCollide?(other) and other.canCollide?(obj) and SpaceDom.GameObject.collideRect(obj, other) and ndgmr.checkPixelCollision(obj.image, other.image, 0, false)
          obj.collide other
          other.collide obj

    @removeObject(obj) for obj in @gameObjects when obj?.isRemove

    @removeParticle particle for particle in @particles when particle?.isComplete()

    # center display on player
    @levelGroup.x = @width * 0.5 - @player.x
    @levelGroup.y = @height * 0.5 - @player.y

    # move background to where player is
    @backgroundGroup.x = (Math.floor(@player.x / 512) - Math.floor(@backgroundGroup.width / 512 * 0.5)) * 512
    @backgroundGroup.y = (Math.floor(@player.y / 512) - Math.floor(@backgroundGroup.height / 512 * 0.5)) * 512

    # update hud
    @HUD.update()

  addObject: (obj) ->
    @gameObjects.push obj if obj not in @gameObjects
    @gameObjGroup.addChild obj

  removeObject: (obj) ->
    @gameObjects.splice(@gameObjects.indexOf(obj), 1) if obj in @gameObjects
    @gameObjGroup.removeChild obj

  addParticle: (particle) ->
    @particles.push particle
    @foregroundGroup.addChild particle

  removeParticle: (particle) ->
    @particles.splice(@particles.indexOf(particle), 1) if particle in @particles
    @foregroundGroup.removeChild particle

  generateBackground: () ->
    bg = @preload.getResult (@level.background.image or 'bg-starfield-sparse')
    for y in [0..Math.floor(@height / bg.height) + 1]
      for x in [0..Math.floor(@width / bg.width) + 1]
        bgobj = new createjs.Bitmap bg
        bgobj.x = bgobj.image.width * x
        bgobj.y = bgobj.image.height * y
        @backgroundGroup.addChild bgobj
        @backgroundGroup.width = bgobj.x + bgobj.image.width
        @backgroundGroup.height = bgobj.y + bgobj.image.height

  generateLevel: ->
    for spawn in @level.spawns
      if spawn.id is 'player'
        ship = @player = new SpaceDom.Ship @preload.getResult(@shiplist['base-fighter'].image), this, @shiplist['base-fighter']
      else
        ship = new SpaceDom.Ship @preload.getResult(@shiplist[spawn.id].image), this, @shiplist[spawn.id]
      ship.x = spawn.x or 0
      ship.y = spawn.y or 0
      ship.rotation = spawn.r or 0
      @addObject ship

    @generateBackground()