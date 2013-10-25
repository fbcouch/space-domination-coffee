# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}
# imports
GameObject = window.SpaceDom.GameObject
Ship = window.SpaceDom.Ship

window.SpaceDom.Projectile = class Projectile extends GameObject
  
  constructor: (@image, @game, specs, @ship) ->
    super @image, @game, specs
    @lifetime = specs.lifetime

    @engine = specs.engine

  update: (delta) ->
    super delta
    
    @lifetime -= delta
    @isRemove = true if @lifetime <= 0

  canCollide: (other) ->
    other isnt @ship and not (other instanceof Projectile)
    
  collide: (other) ->
    other.takeDamage? this
    @isRemove = true
    @ship.stats.shots_hit++
