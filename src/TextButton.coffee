# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.TextButton = class TextButton extends createjs.Container

  constructor: (@text, @button_style) ->
    @initialize()
    @button_style or=
      unselected:
        font: "bold 24px Courier"
        color: "#FFFFFF"
      selected:
        font: "bold 24px Courier"
        color: "#FF0000"

    @state = 'unselected'
    @textObj = new createjs.Text()
    @addChild @textObj

    @update()

  update: (delta) ->

    if @textObj.text isnt @text or @textObj.font isnt @button_style[@state]?.font or @textObj.color isnt @button_style[@state]?.color

      @textObj.text = @text
      @textObj.font = @button_style[@state]?.font
      @textObj.color = @button_style[@state]?.color
      @textObj.textAlign = "left"

      {width: @width, height: @height} = @textObj.getBounds()

  select: () -> @state = 'selected'
  deselect: () -> @state = 'unselected'