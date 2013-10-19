# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.AIShip = class AIShip extends SpaceDom.Ship
  constructor: (@image, @game, @proto) ->
    super @image, @game, @proto

    @ai =
      patrol: {x: 0, y: 0, w: 1000, h: 1000}
      attack_range_sq: 500*500

    @team = 2

  update: (delta) ->
    super delta

    return if @isRemove # don't bother with AI if we're on our way out

    @target = null if @target?.isRemove

    if not @target?
      # find a target if we can
      for obj in @game.gameObjects
        if obj instanceof SpaceDom.Ship and obj isnt @ and obj.team isnt @team
          if (not @target? and AIShip.get_dist_sq(@, obj) < @ai.attack_range_sq) \
              or (AIShip.get_dist_sq(@, obj) < @ai.attack_range_sq and AIShip.get_dist_sq(@, @target) > AIShip.get_dist_sq(@, obj))
            @target = obj

    if @target?
      @targetPos =
        x: @target.x
        y: @target.y

      @fire() if @canFire() and Math.random() < 0.05

    if not @targetPos?
      @targetPos =
        x: Math.floor(Math.random() * @ai.patrol.w + @ai.patrol.x)
        y: Math.floor(Math.random() * @ai.patrol.h + @ai.patrol.y)

    local = @parent.localToLocal @targetPos.x, @targetPos.y, @
    if @hitTest local.x, local.y
      @targetPos = null

    if @targetPos?
#      if not @target_box?
#        @target_box = new createjs.Shape()
#        @target_box.graphics.beginFill("#0000ff").drawRect(0, 0, 10, 10)
#        @addChild @target_box
#
#      {x: @target_box.x, y: @target_box.y} = local

      angle = Math.atan2 @targetPos.y - @y, @targetPos.x - @x
      angle *= SpaceDom.RAD_TO_DEG

      diff = AIShip.get_angle_diff(@rotation, angle)
      if Math.abs(diff) > @specs.rotate * delta
        @rotate delta, diff < 0
      @thrust delta

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

  @get_dist_sq: (ship1, ship2) ->
    Math.pow(ship1.x - ship2.x, 2) + Math.pow(ship1.y - ship2.y, 2)