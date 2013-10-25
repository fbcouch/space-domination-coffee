# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.LevelScreen = class LevelScreen extends SpaceDom.Screen
  constructor: (@preload, @game, @level_id) ->
    super @preload, @game
    @gameObjects = []
    @particles = []

    @level = @preload.getResult @level_id
    @shiplist = @preload.getResult 'shiplist'

    @gameState = ''

    @HUD = new SpaceDom.HUD @

  show: () ->
    @levelGroup = new createjs.Container()

    @backgroundGroup = new createjs.Container()
    @foregroundGroup = new createjs.Container()
    @gameObjGroup = new createjs.Container()

    @levelGroup.addChild @backgroundGroup
    @levelGroup.addChild @gameObjGroup
    @levelGroup.addChild @foregroundGroup

    @addChild @levelGroup
    @addChild @HUD

    menuItems = [
      { text: 'Continue', action: 'unpause' },
      { text: 'Quit', action: 'quit' }
    ]
    @_pauseMenu = new SpaceDom.UpdateContainer()

    @_pauseMenuTitle = new createjs.Text "PAUSED", "bold 40px Arial", "#3366FF"
    @_pauseMenu.addChild @_pauseMenuTitle

    menu = new SpaceDom.TextMenu menuItems, null, (item) =>
      switch item.action
        when 'quit' then @game.setMenuScreen()
        when 'unpause'
          if @gameState is 'paused' then @unpause() else @game.setScreen new LevelScreen @preload, @game, @level_id

    @_pauseMenu.addChild menu
    menu.y = 50
    {width: @_pauseMenu.width, height: @_pauseMenu.height} = @_pauseMenu.getBounds()

    @_pauseMenuTitle.textAlign = 'center'
    @_pauseMenuTitle.x = @_pauseMenu.width * 0.5
    menu.x = (@_pauseMenu.width - menu.width) * 0.5

    @_pauseMenu.x = (@width - @_pauseMenu.width) * 0.5
    @_pauseMenu.y = (@height - @_pauseMenu.height) * 0.5

    @generateLevel()

    @pause()

  resize: (@width, @height) ->
    if @backgroundGroup?
      @backgroundGroup.removeAllChildren()
      @generateBackground()

    @HUD.resize @width, @height

  update: (delta, keys) ->
    super(delta, keys)

    # prevent bleed-thru of input from menu
    if not @first_pass_done?
      @first_pass_done = true
      keys[key] = false for key of keys

    switch @gameState
      when 'paused'
        @_pauseMenu.update delta, keys

        if keys.pause
          @unpause() if not @cancel_key_down
          @cancel_key_down = true
        else
          @cancel_key_down = false

      when 'running'
        if keys.left and not keys.right
          @player.rotate delta, true
        else if keys.right and not keys.left
          @player.rotate delta
        if keys.accel and not keys.brake
          @player.thrust delta
        else if keys.brake and not keys.accel and (@player.vel.x isnt 0 or @player.vel.y isnt 0)
          @player.thrust delta, true
        else
          @player.accel.x = @player.accel.y = 0

        if keys.altfire
          @player.switchWeapon() if not @altfire_key_down
          @altfire_key_down = true
        else
          @altfire_key_down = false

        @player.fire() if keys.fire

        if keys.pause
          @pause() if not @cancel_key_down
          @cancel_key_down = true
        else
          @cancel_key_down = false

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

        if @player.isRemove
          @endGame false

        if (obj for obj in @gameObjects when obj instanceof SpaceDom.Ship and obj isnt @player and not obj.isRemove and obj.team isnt @player.team).length is 0
          @endGame true

      when 'gameover'
        @_pauseMenu.update delta, keys

    # center display on player
    @levelGroup.x = @width * 0.5 - @player.x
    @levelGroup.y = @height * 0.5 - @player.y

    # move background to where player is
    @backgroundGroup.x = (Math.floor(@player.x / 512) - Math.floor(@backgroundGroup.width / 512 * 0.5)) * 512
    @backgroundGroup.y = (Math.floor(@player.y / 512) - Math.floor(@backgroundGroup.height / 512 * 0.5)) * 512

    # update hud
    @HUD.update()

  endGame: (victory) ->
    @_pauseMenuTitle.text = if victory then "VICTORY" else "DEFEAT"
    @addChild @_pauseMenu
    @gameState = 'gameover'
    console.log @player.stats
    @game.processStats @level_id, @player.stats, victory

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
        ship = new SpaceDom.AIShip @preload.getResult(@shiplist[spawn.id].image), this, @shiplist[spawn.id]
      ship.x = spawn.x or 0
      ship.y = spawn.y or 0
      ship.rotation = spawn.r or 0
      ship.team = spawn.team or (if spawn.id is 'player' then 1 else 2)
      @addObject ship

    @generateBackground()

  pause: () =>
    @addChild @_pauseMenu
    @gameState = 'paused'

  unpause: () =>
    @removeChild @_pauseMenu
    @gameState = 'running'