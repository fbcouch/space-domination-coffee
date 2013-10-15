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
        font: "20px Arial"
        color: "#FFFFFF"
      selected:
        font: "20px Arial"
        color: "#FF3333"

    @state = 'unselected'
    @textObj = new createjs.Text()
    @addChild @textObj

    @update()

  update: (delta) ->

    if @textObj.text isnt @text or @textObj.font isnt @button_style[@state]?.font or @textObj.color isnt @button_style[@state]?.color

      @textObj.text = @text
      @textObj.font = @button_style[@state]?.font
      @textObj.color = @button_style[@state]?.color
      @textObj.textAlign = "center"

      {width: @width, height: @height} = @textObj.getBounds()

  select: () -> @state = 'selected'
  deselect: () -> @state = 'unselected'