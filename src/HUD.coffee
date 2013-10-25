# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.HUD = class HUD extends createjs.Container

  constructor: (@game) ->
    @initialize()

    @shipOverlays = []

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