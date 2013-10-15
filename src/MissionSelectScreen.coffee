# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.MissionSelectScreen = class MissionSelectScreen extends SpaceDom.Screen
  _buttons: []

  constructor: (@preload, @game) ->
    super(@preload, @game)
    @levels = (@preload.getResult(level) for level in @preload.getResult('missions'))

    @keysDown = {}

  show: ->
    super()

  resize: (@width, @height) ->
    super(@width, @height)

    @removeAllChildren()

    @_buttons = []
    for level, l in @levels when level isnt null
      btn = new SpaceDom.TextButton level.title
      btn.x = @width * 0.5
      btn.y = 100 * (l + 1)
      btn.action = l
      @_buttons.push btn
      @addChild btn

    @_selected = 0
    @_buttons[@_selected]?.select()

  update: (delta, keys) ->
    super(delta, keys)

    @_buttons[@_selected]?.deselect()

    @_selected-- if keys.accel and not @keysDown.accel
    @_selected++ if keys.brake and not @keysDown.brake

    if keys.fire and not @keysDown.fire
      @game.setScreen new SpaceDom.LevelScreen @preload, @game, @preload.getResult('missions')[@_buttons[@_selected].action]

    @_selected %= @_buttons.length
    @_buttons[@_selected]?.select()

    for key, val of keys
      @keysDown[key] = val

#    console.log @_selected
    child.update?(delta, keys) for child in @children