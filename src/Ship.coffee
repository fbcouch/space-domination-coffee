# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

GameObject = window.SpaceDom.GameObject

window.SpaceDom.Ship = class Ship extends GameObject
  status:
    curhp: 0
    maxhp: 0
    hregen: 0
    shield: 0
    maxshield: 0
    sregen: 0
    armor: 0
    weapons: []  
    curweapon: -1
  
  constructor: (@image, @game, @specs) ->
    super @image, @game, @specs
    
    weapon =
      image: 'laser-red1'
      points: [{x: 40, y: 2}, {x: 40, y: 77}]
      maxammo: 10
      curammo: 10
      regen: 0.1 # sec
      regentimer: 0
      firerate: 0.05 # sec
      firetimer: 0
      projectile:
        damage: 5
        vel: 1000
        accel: 0
        initvel: 1000
    
    @status.weapons.push weapon
    @status.curweapon = 0
    
  canFire: ->
    false if @status.curweapon < 0 or @status.curweapon >= @status.weapons.length
    wp = @status.weapons[@status.curweapon]
    wp.curammo >= wp.points.length and wp.firetimer <= 0
    
  fire: ->
    if not @canFire() then return
    
    # setting up some objects that will be reused while looping
    angle = this.rotation * Math.PI / 180   # need angle in radians
    cos = Math.cos angle
    sin = Math.sin angle
    
    offsetXY =
      x: 0
      y: 0
    offset =
      angle: 0
      mag: 0
    
    wp = @status.weapons[@status.curweapon]
    projectiles = for point in wp.points
      proj = new GameObject @game.preload.getResult(wp.image), @game, wp.projectile
      
      offsetXY.x = point.x - this.regX
      offsetXY.y = point.y - this.regY
      offset.angle = Math.atan2 offsetXY.y, offsetXY.x
      offset.mag = Math.sqrt offsetXY.x * offsetXY.x + offsetXY.y * offsetXY.y
      
      proj.x = this.x + offset.mag * Math.cos offset.angle + angle
      proj.y = this.y + offset.mag * Math.sin offset.angle + angle
      proj.vel.x = wp.projectile.initvel * cos
      proj.vel.y = wp.projectile.initvel * sin
      proj.accel.x = wp.projectile.accel * cos
      proj.accel.y = wp.projectile.accel * sin
      proj.rotation = this.rotation
      
      @game.addObject proj
      wp.curammo--
    wp.firetimer = wp.firerate
    
  update: (delta) ->
    super delta
    
    for wp in @status.weapons
      
      if wp.firetimer > 0
        wp.firetimer -= delta
        wp.firetimer = 0 if wp.firetimer <= 0
      
      
      wp.regentimer -= delta
      if wp.regentimer <= 0
        wp.regentimer = wp.regen
        wp.curammo++
        wp.curammo = wp.maxammo if wp.curammo > wp.maxammo
      
    
  canCollide: (other) ->
    super other
    
  collide: (other) ->
    super other
    