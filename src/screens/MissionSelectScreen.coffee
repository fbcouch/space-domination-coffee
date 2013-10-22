# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.MissionSelectScreen = class MissionSelectScreen extends SpaceDom.Screen

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

    titletxt = new createjs.Text "SPACE DOMINATION", "bold 40px Arial", "#3366FF"
    titletxt.textAlign = "center"
    titletxt.y = 100
    titletxt.x = @width * 0.5

    @addChild titletxt

    menuContainer = new SpaceDom.TextMenu ({text: level.title, level: l} for level, l in @levels), null, (item) =>
      @game.setScreen new SpaceDom.LevelScreen @preload, @game, @preload.getResult('missions')[item.level]

    menuContainer.x = (@width - menuContainer.width) * 0.5
    menuContainer.y = (@height - menuContainer.height) * 0.5

    @addChild menuContainer

  update: (delta, keys) ->
    super(delta, keys)

    if not @first_pass_done?
      @first_pass_done = true
      keys[key] = false for key of keys

    child.update? delta, keys for child in @children