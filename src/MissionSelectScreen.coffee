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

    bg = new createjs.Bitmap @preload.getResult 'bg-menu'
    bg.x = (@width - bg.image.width) * 0.5
    bg.y = (@height - bg.image.height) * 0.5
    @addChild bg

    menuContainer = new createjs.Container()

    titletxt = new createjs.Text "SPACE DOMINATION", "bold 40px Arial", "#3366FF"
    titletxt.textAlign = "center"
    titletxt.y = 100
    titletxt.x = @width * 0.5

    @addChild titletxt

    @_buttons = []
    for level, l in @levels when level isnt null
      btn = new SpaceDom.TextButton level.title
      btn.y = 100 * l
      btn.action = l
      @_buttons.push btn
      menuContainer.addChild btn

    { x: x, y: y, width: menuContainer.width, height: menuContainer.height } = menuContainer.getBounds()
    menuContainer.x = (@width - menuContainer.width) * 0.5
    menuContainer.y = (@height - menuContainer.height) * 0.5
    @addChild menuContainer

    for btn in @_buttons
      btn.x = (menuContainer.width - btn.getBounds().width) * 0.5

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
    update_children = (obj, delta, keys) ->
      for child in obj.children
        child.update?(delta, keys)
        if child.children?
          update_children child, delta, keys
    update_children @, delta, keys
    #child.update?(delta, keys) for child in @children