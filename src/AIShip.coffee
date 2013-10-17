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
      @targetPos = @localToLocal Math.floor(Math.random() * 400 + 200), Math.floor(Math.random() * 400 + 200), @parent

    local = @parent.localToLocal @targetPos.x, @targetPos.y, @
    if @hitTest local.x, local.y
      @targetPos = null

    if @targetPos?
      if not @target_box?
        @target_box = new createjs.Shape()
        @target_box.graphics.beginFill("#0000ff").drawRect(0, 0, 10, 10)
        @addChild @target_box

      {x: @target_box.x, y: @target_box.y} = local

      angle = Math.atan2 @targetPos.y - @y, @targetPos.x - @x
      angle *= SpaceDom.RAD_TO_DEG

      diff = AIShip.get_angle_diff(@rotation, angle)
      console.log "#{@rotation}, #{angle}, #{diff}"
      if Math.abs(diff) > @specs.rotate * delta
        @rotate delta, diff < 0
      @thrust delta

#      console.log 'gogo!'

  @get_angle_diff: (angle1, angle2) ->
    angle1 -= 360 if angle1 >= 360
    angle1 += 360 if angle1 < 0

    angle2 -= 360 if angle2 >= 360
    angle2 += 360 if angle2 < 0

    diff1 = angle2 - angle1

    angle1 -= 360 if angle1 > 180
    angle2 -= 360 if angle2 > 180

    diff2 = angle2 - angle1

    return if Math.abs(diff1) < Math.abs(diff2) then diff1 else diff2