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
    @gameTime = 0

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
        when 'quit'
          @endGame false if @gameState isnt 'gameover'
          @game.setMenuScreen()
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
        @gameTime += delta
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

        if @checkTriggers()
          # continue checking conditions
          if @player.isRemove
            @endGame false

          # are all active ships either on the players team or dead?
          if (obj for obj in @gameObjects when obj instanceof SpaceDom.Ship and obj isnt @player and not obj.isRemove and obj.team isnt @player.team).length is 0
            # are there any ships that must be destroyed as a condition of victory?
            if (trigger for trigger in @triggers when not trigger.completed and trigger.type is 'destroy' and trigger.action is 'primary').length is 0
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

  # returns false if the game ends
  checkTriggers: ->
    primary_objs_left = primary_objs_total = 0
    for trigger in @triggers
      if not trigger.completed
        switch trigger.type
          when 'timer'
            if @gameTime >= trigger.value
              trigger.completed = true
              result = @doAction(trigger.action)
              return false if not result

          when 'destroy', 'survive'
            remaining = trigger.ships.reduce(((prev, ship) -> if not ship.isRemove or ship.status.curhp > 0 then prev + 1 else prev), 0)
            if remaining is 0
              trigger.completed = true
              return false if not @doAction trigger.action

      if trigger.action is 'primary'
        primary_objs_left++ if not trigger.completed
        primary_objs_total++

        if trigger.completed and trigger.type is 'survive'
          @endGame false
          return false

    if primary_objs_left is 0 and primary_objs_total > 0
      @endGame true
      return false
    true

  # returns false if the game ends
  doAction: (action, ships) ->
    if typeof action is "string"
      switch action
        when 'defeat'
          @endGame false
          return false
        when 'victory'
          @endGame true
          return false
        when 'spawn'
          @addObject ship for ship in ships
    else if typeof action is "object"
      for key, value of action
        return false if not @doAction key, value
    true

  endGame: (victory) ->
    @_pauseMenuTitle.text = if victory then "VICTORY" else "DEFEAT"
    @addChild @_pauseMenu
    @gameState = 'gameover'
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
    allships = []
    for spawn in @level.spawns
      if spawn.id is 'player'
        ship = @player = new SpaceDom.Ship @preload.getResult(@shiplist['base-fighter'].image), this, @shiplist['base-fighter']
      else
        ship = new SpaceDom.AIShip @preload.getResult(@shiplist[spawn.id].image), this, @shiplist[spawn.id]
      ship.x = spawn.x or 0
      ship.y = spawn.y or 0
      ship.rotation = spawn.r or 0
      ship.team = spawn.team or (if spawn.id is 'player' then 1 else 2)
      ship.gid = spawn.gid
      @addObject ship
      allships.push ship

    @triggers = []
    for trigger in @level.triggers or []
      tg = {}
      tg[key] = val for key, val of trigger
      if tg.type in ["destroy", "survive"]
        tg.ships = (ship for ship in allships when ship.gid is tg.value or (typeof ship.gid is 'object' and tg.value in ship.gid))
      if typeof tg.action is "object"
        for key, val of tg.action
          tg.action[key] = (ship for ship in allships when ship.gid is val or (typeof ship.gid is 'object' and val in ship.gid))
          @removeObject ship for ship in tg.action[key] if key is 'spawn'

      @triggers.push tg

    @generateBackground()

  pause: () =>
    @addChild @_pauseMenu
    @gameState = 'paused'

  unpause: () =>
    @removeChild @_pauseMenu
    @gameState = 'running'

  recordKill: (killer, victim) ->
    # for now, only bother if we have a victim and the killer is the player
    if killer? and killer is @player and victim.team isnt killer.team
      @xp += victim.proto.xp
      @money += victim.proto.bounty