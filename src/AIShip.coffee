# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.AIShip = class AIShip extends SpaceDom.Ship
  constructor: (@image, @game, @proto) ->
    super @image, @game, @proto

  update: (delta) ->
    super delta

    return if @isRemove # don't bother with AI if we're on our way out

    if not @targetPos?
      @targetPos =
        x: @x + Math.floor(Math.random() * 450 + 50)
        y: @y + Math.floor(Math.random() * 450 + 50)

    if @hitTest @targetPos.x, @targetPos.y
      @targetPos = null

#    if @targetPos?
#      @accel.x = 10
#      console.log 'gogo!'