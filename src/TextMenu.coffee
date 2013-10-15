# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.TextMenu = class TextMenu extends createjs.Container

  constructor: (@items, @style, @handler) ->
    super()
    @initialize()

    @style or=
      layout: 'vertical'
      halign: 'center'
      padding:
        x: 0
        y: 100

    @_buttons = []
    @_selected = -1

    for item, i in @items
      btn = new SpaceDom.TextButton item.text
      btn.action = i
      @_buttons.push btn
      @addChild btn

    @_selected = 0 if @_buttons.length > 0
    @_buttons[@_selected]?.select()

    @layout()

    @keysDown = {}

  layout: ->
    for btn, i in @_buttons
      if @style.layout is 'horizontal'
        #
      else
        btn.x = 0
        btn.y = (@_buttons[i-1]?.y + @_buttons[i-1]?.height or 0) + @style.padding.y

    { width: @width, height: @height } = @getBounds()

    if @style.halign is 'center'
      btn.x = (@width - btn.width) * 0.5 for btn in @_buttons

  update: (delta, keys) ->
    @_buttons[@_selected]?.deselect()

    # TODO update this logic to handle layouts
    @_selected-- if keys.accel and not @keysDown.accel
    @_selected++ if keys.brake and not @keysDown.brake

    if keys.fire and not @keysDown.fire
      @handler @items[@_buttons[@_selected].action]

    @_selected = @_buttons.length - @_selected if @_selected < 0
    @_selected %= @_buttons.length
    @_buttons[@_selected]?.select()

    for key, val of keys
      @keysDown[key] = val

    child.update? delta, keys for child in @children