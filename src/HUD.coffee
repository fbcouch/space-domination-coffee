# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.HUD = class HUD extends createjs.Container

  constructor: (@game) ->
    @initialize()

    @texts = []

  update: () ->
    for obj in @game.gameObjects when obj.hud and not @hasText(obj)
      # create a text
      text = new createjs.Text '', 'normal 14px sans-serif', '#0F0'
      text.textAlign = 'center'
      text.gameobj = obj
      @texts.push text
      @addChild text

    for text in @texts
      text.text = "HP: #{text.gameobj.status?.curhp}/#{text.gameobj.status?.maxhp}"
      text.x = text.gameobj.x
      text.y = text.gameobj.y + text.gameobj.height * 0.5

    for i in [0...@texts.length] when @texts[i]?.gameobj.isRemove
      @removeChild @texts[i]
      @texts.splice(i, 1)

  hasText: (obj) ->
    return true for text in @texts when text.gameobj is obj
    false