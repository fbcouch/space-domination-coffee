# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.HUD = class HUD extends createjs.Container

  constructor: (@game) ->
    @initialize()

    @shipOverlays = []
    @objectives =
      primary: []
      secondary: []

    @healthBar = new HUDProgressBar 'HULL  |----------|', 'normal 32px Courier', '#0F0'
    @shieldBar = new HUDProgressBar 'SHIELD|----------|', 'normal 32px Courier', '#00F'

    @gameTimer = new createjs.Text 'Mission Time:', 'normal 32px Courier', '#CCC'

    @addChild @healthBar
    @addChild @shieldBar
    @addChild @gameTimer

  resize: (@width, @height) ->
    @healthBar.y = @height - @healthBar.getBounds().height - 10
    @shieldBar.y = @healthBar.y - @shieldBar.getBounds().height - 10
    @healthBar.x = @width - @healthBar.getBounds().width - 10
    @shieldBar.x = @healthBar.x

    @weaponStatus?.y = @height - @weaponStatus.getBounds().height - 10

    y = @gameTimer.y + @gameTimer.getBounds().height
    minx = @width
    for obj in @objectives.primary
      obj.y = y + (obj.height or obj.getBounds().height) + 10
      y = obj.y
      obj.x = @width - (obj.width or obj.getBounds().width)
      minx = obj.x if obj.x < minx
    for obj in @objectives.secondary
      obj.y = y + (obj.height or obj.getBounds().height) + 10
      y = obj.y
      obj.x = @width - (obj.width or obj.getBounds().width)
      minx = obj.x if obj.x < minx

    obj.x = minx for obj in @objectives.primary
    obj.x = minx for obj in @objectives.secondary
    @objectives.primary[0]?.x = minx - 20
    @objectives.secondary[0]?.x = minx - 20

  update: () ->
    if not @weaponStatus?
      @weaponStatus = new createjs.Container()

      for weapon, w in @game.player.status.weapons
        wpbar = new HUDProgressBar "#{weapon.label}|#{('-' for i in [0...weapon.maxammo]).join('')}|", 'normal 32px Courier', '#999'
        @weaponStatus.addChild wpbar
        wpbar.y = w * (wpbar.getBounds().height + 10)
      @addChild @weaponStatus
      @weaponStatus?.y = @height - @weaponStatus.getBounds().height - 10

      @weaponStatus.update = =>
        for weapon, w in @game.player.status.weapons
          wpbar = @weaponStatus.children[w]
          wpbar.update weapon.curammo / weapon.maxammo
          wpbar.color = (if @game.player.status.curweapon is w then '#F00' else '#999')

    @healthBar.update @game.player.status.curhp / @game.player.status.maxhp
    if @game.player.status.maxshield? and @game.player.status.maxshield > 0
      @shieldBar.update @game.player.status.shield / @game.player.status.maxshield

    @weaponStatus.update()

    for obj in @game.gameObjects when obj.hud and not @hasOverlay(obj)
      # create an overlay
      overlay = new HUDShipOverlay(obj)
      @shipOverlays.push overlay
      @addChild overlay

    for text in @shipOverlays
      text.update(@game.levelGroup)

    for i in [0...@shipOverlays.length] when @shipOverlays[i]?.ship.isRemove
      @removeChild @shipOverlays[i]
      @shipOverlays.splice(i, 1)

    @gameTimer.x = @width - @gameTimer.getBounds()?.width - 10
    secs = Math.floor(@game.gameTime % 60)
    @gameTimer.text = "Mission Time: #{Math.floor(@game.gameTime / 60)}:#{if secs < 10 then '0' else ''}#{secs}"

    if not @init_objectives
      @init_objectives = true
      for trigger in @game.triggers
        obj = new HUDObjective(trigger, @game)
        if trigger.action is 'primary' or (typeof trigger.action is 'object' and 'primary' in (key for key of trigger.action))
          @addChild obj
          @objectives.primary.push obj
        else if trigger.action is 'secondary' or (typeof trigger.action is 'object' and 'secondary' in (key for key  of trigger.action))
          @addChild obj
          @objectives.secondary.push obj

      if @objectives.primary.length isnt 0
        prim = new createjs.Text 'PRIMARY OBJECTIVES', 'normal 14px Courier', '#FF0'
        @addChild prim
        @objectives.primary.unshift prim
      if @objectives.secondary.length isnt 0
        sec = new createjs.Text 'SECONDARY OBJECTIVES', 'normal 14px Courier', '#FF0'
        @addChild sec
        @objectives.secondary.unshift sec

      @resize @width, @height

    obj.update?() for obj in @objectives.primary
    obj.update?() for obj in @objectives.secondary

  hasOverlay: (obj) ->
    return true for overlay in @shipOverlays when overlay.ship is obj
    false

class HUDProgressBar extends createjs.Text
  constructor: (text, style, color, label, boxes) ->
    super text, style, color
    @initialize(text, style, color)

    @boxes = boxes or text.match(/\|\-+\|/g)?[0].length - 2
    @label = label or text.match(/^[^-\|]+/)?[0]

  update: (proportion) ->
    filled = Math.floor(proportion * @boxes)
    @text = "#{@label}|#{('#' for h in [0...filled]).join('')}#{('-' for h in [filled...@boxes]).join('')}|"

class HUDShipOverlay extends createjs.Container
  constructor: (@ship) ->
    @initialize()
    @healthBar = new HUDProgressBar 'HP|-----|', 'normal 14px Courier', '#0F0'
    @shieldBar = new HUDProgressBar 'SP|-----|', 'normal 14px Courier', '#00F'

    @healthBar.y = @shieldBar.getBounds().height + 5

    @addChild @healthBar
    @addChild @shieldBar if @ship.status?.maxshield > 0

    {width: @width, height: @height} = @getBounds()

  update: (view) ->
    @healthBar.update @ship.status?.curhp / @ship.status?.maxhp
    @shieldBar.update @ship.status?.shield / @ship.status?.maxshield if @ship.status?.maxshield > 0

    @x = view.x + @ship.x - @width * 0.5
    @y = view.y + @ship.y + @ship.height * 0.5

class HUDObjective extends createjs.Text
  constructor: (@trigger, @level) ->
    @initialize @trigger.message, 'normal 14px Courier', '#FF0'

    {width: @width, height: @height} = @getBounds() if @text isnt ''

    if @trigger.ships
      for ship in @trigger.ships
        ship.obj_marker = new createjs.Bitmap @level.preload.getResult (if @trigger.type is 'survive' then 'obj-pointer-green' else 'obj-pointer-yellow')
        ship.obj_marker.regX = ship.obj_marker.image.width * 0.5
        ship.obj_marker.regY = ship.obj_marker.image.height * 0.5


  update: ->
    if @trigger.completed
      @color = if @trigger.failed then '#F00' else '#0F0'
      @parent.removeChild ship.obj_marker for ship in @trigger.ships
    else
      @color = '#FF0'
      for ship in @trigger.ships
        if ship.parent is null
          @parent.removeChild ship.obj_marker
        else
          if (ship.x > - @level.levelGroup.x + @level.width or ship.x < - @level.levelGroup.x or
              ship.y > - @level.levelGroup.y + @level.height or ship.y < - @level.levelGroup.y)
            @parent.addChild ship.obj_marker if ship.obj_marker.parent is null
            {x: ship.obj_marker.x, y: ship.obj_marker.y} = @get_screen_intersection ship
          else
            @parent.removeChild ship.obj_marker if ship.obj_marker.parent isnt null

  get_screen_intersection: (ship) ->
    coords = ship.localToGlobal(ship.regX, ship.regY)
    screen_slope = @parent.height / @parent.width
    slope_to_coords = (@parent.height * 0.5 - coords.y) / (@parent.width * 0.5 - coords.x)
    b_to_coords = coords.y - (coords.x * slope_to_coords)

    if (coords.x) * screen_slope >= (coords.y)
      console.log 'yes'
      if 0 > slope_to_coords >= - screen_slope
        return {x: @parent.width, y: slope_to_coords * @parent.width + b_to_coords}
      else
        return {x: - b_to_coords / slope_to_coords, y: 0}
    else
      console.log 'no: ' + slope_to_coords
      if 0 > slope_to_coords > - screen_slope
        return {x: 0, y: b_to_coords}
      else
        return {x: (@parent.height - b_to_coords) / slope_to_coords, y: @parent.height}

    return {x: 0, y: 0}