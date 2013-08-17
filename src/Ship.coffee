# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

GameObject = window.SpaceDom.GameObject

window.SpaceDom.Ship = class Ship extends GameObject
  curhp: 0
  maxhp: 0
  shield: 0
  maxshield: 0
  armor: 0
  weapons: []  
  curweapon: -1
  
  constructor: (@image, @game, @specs) ->
    super @image, @game, @specs
    
  update: (delta) ->
    super delta
    
  canCollide: (other) ->
    super other
    
  collide: (other) ->
    super other
    
