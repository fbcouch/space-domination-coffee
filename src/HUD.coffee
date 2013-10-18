# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.HUD = class HUD extends createjs.Container

  constructor: (@game) ->
    @initialize()

    @texts = []

    @healthBar = new HUDProgressBar 'HULL  |----------|', 'normal 32px Courier', '#0F0'
    @shieldBar = new HUDProgressBar 'SHIELD|----------|', 'normal 32px Courier', '#00F'

    @addChild @healthBar
    @addChild @shieldBar

  resize: (@width, @height) ->
    @healthBar.y = @height - @healthBar.getBounds().height - 10
    @shieldBar.y = @healthBar.y - @shieldBar.getBounds().height - 10
    @healthBar.x = @width - @healthBar.getBounds().width - 10
    @shieldBar.x = @healthBar.x

  update: () ->
    @healthBar.update @game.player.status.curhp / @game.player.status.maxhp
    if @game.player.status.maxshield? and @game.player.status.maxshield > 0
      @shieldBar.update @game.player.status.shield / @game.player.status.maxshield

    for obj in @game.gameObjects when obj.hud and not @hasText(obj)
      # create a text
      text = new HUDProgressBar 'HP|-----|', 'normal 14px Courier', '#0F0'
      text.textAlign = 'center'
      text.gameobj = obj
      @texts.push text
      @addChild text

    for text in @texts
      text.update text.gameobj.status?.curhp / text.gameobj.status?.maxhp
      text.x = @game.levelGroup.x + text.gameobj.x
      text.y = @game.levelGroup.y + text.gameobj.y + text.gameobj.height * 0.5

    for i in [0...@texts.length] when @texts[i]?.gameobj.isRemove
      @removeChild @texts[i]
      @texts.splice(i, 1)

  hasText: (obj) ->
    return true for text in @texts when text.gameobj is obj
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