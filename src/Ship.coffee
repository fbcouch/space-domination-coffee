# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

GameObject = window.SpaceDom.GameObject
Projectile = window.SpaceDom.Projectile

window.SpaceDom.Ship = class Ship extends GameObject
  hud: true

  constructor: (@image, @game, @proto) ->
    super @image, @game, @proto.specs

    @status =
      curhp: 0
      maxhp: 0
      hregen: 0
      shield: 0
      maxshield: 0
      sregen: 0
      armor: 0
      weapons: []
      curweapon: -1

    @status[key] = value for key, value of @specs

    @status[key] = value for key, value of @proto.specs
    
    @status.weapons.push weapon for weapon in @proto.weapons if @proto.weapons?
    @status.curweapon = 0

    @particle_timer = 0
    
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
      proj = new Projectile @game.preload.getResult(wp.image), @game, wp.projectile, this
      
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

    if @status.curhp <= 0
      @isRemove = true
      if @proto.destroyed?.particle?
        particle = new SpaceDom.Particle @proto.destroyed.particle, @game
        particle.x = @x
        particle.y = @y
        @game.addParticle particle

    @particle_timer -= delta
    if @particle_timer <= 0 and (@accel.x isnt 0 or @accel.y isnt 0) and @proto.engine?
      for point in @proto.engine.points
        particle = new SpaceDom.Particle @proto.engine.particle, @game
        offsetXY = { x: point.x - @regX, y: point.y - @regY }
        offset = { angle: 0, mag: 0 }
        offset.angle = Math.atan2 offsetXY.y, offsetXY.x
        offset.mag = Math.sqrt offsetXY.x * offsetXY.x + offsetXY.y * offsetXY.y
        angle = this.rotation * Math.PI / 180

        particle.x = @x + offset.mag * Math.cos offset.angle + angle
        particle.y = @y + offset.mag * Math.sin offset.angle + angle

        @game.addParticle particle
      @particle_timer = 0.1

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

  takeDamage: (other) ->
    if other instanceof Ship
      console.log 'collide ship' # TODO take some damage?
    else if other instanceof Projectile
      @status.shield -= other.specs.damage
      if @status.shield < 0
        @status.curhp += @status.shield
        @status.shield = 0
        particle = new SpaceDom.Particle other.specs['hull'].particle or 'hull-hit', @game
      else
        particle = new SpaceDom.Particle other.specs['shield'].particle or other.specs['hull'] or 'hull-hit', @game
      if particle?
        particle.x = other.x
        particle.y = other.y
        @game.addParticle particle