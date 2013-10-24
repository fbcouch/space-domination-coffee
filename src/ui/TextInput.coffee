# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.TextInput = class TextInput extends createjs.Container
  constructor: (@text, @style, @filter) ->
    @initialize()
    @style or=
      font: "bold 24px Courier"
      color: "#FFFFFF"
      cursor_frequency: 0.5

    @filter or= /[A-Za-z0-9\-]/

    @textElement = new createjs.Text "", @style.font, @style.color
    @cursor = new createjs.Text "_", @style.font, @style.color
    @addChild @textElement
    @addChild @cursor

    @update()

  update: (delta) ->
    if @textElement.text isnt @text
      @textElement.text = @text
      @textElement.color = @style.color
      @textElement.font = @style.font
      {width: @textElement.width, height: @textElement.height} = @textElement.getBounds() or {width: 0, height: 0}
      @cursor.x = @textElement.x + @textElement.width
      @cursor.y = @textElement.y
      {width: @width, height: @height} = @getBounds() if @text isnt ''

    @cursor_timer -= delta
    if not @cursor_timer or @cursor_timer <= 0
      @cursor_timer = @style.cursor_frequency
      if @cursor.text isnt '' then @cursor.text = '' else @cursor.text = '_'

  keydown: (e) ->
    if e.keyCode is 8 # backspace
      @text = @text.slice(0, -1)

    char = String.fromCharCode(e.keyCode)
    char = char.toLowerCase() if not e.shiftKey
    @text += char if @filter.test char