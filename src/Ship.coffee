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

    weaponlist = @game.preload.getResult('weapons')
    if @proto.weapons?
      for weapon in @proto.weapons
        if typeof weapon is 'object'
          wp = JSON.parse(JSON.stringify(weaponlist[weapon.id]))
          wp[key] = val for key, val of weapon
          @status.weapons.push wp
        else
          @status.weapons.push JSON.parse JSON.stringify weaponlist[weapon]

    @status.curweapon = 0 if @status.weapons.length > 0

    @team = 1

    @engine = @proto.engine
    
  canFire: ->
    return false if @status.curweapon < 0 or @status.curweapon >= @status.weapons.length
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

      rad = point.r * SpaceDom.DEG_TO_RAD
      
      proj.x = this.x + offset.mag * Math.cos offset.angle + angle
      proj.y = this.y + offset.mag * Math.sin offset.angle + angle
      proj.vel.x = wp.projectile.initvel * (if point.r? then Math.cos angle + rad else cos)
      proj.vel.y = wp.projectile.initvel * (if point.r? then Math.sin angle + rad else sin)
      proj.accel.x = wp.projectile.accel * (if point.r? then Math.cos angle + rad else cos)
      proj.accel.y = wp.projectile.accel * (if point.r? then Math.sin angle + rad else sin)
      proj.rotation = this.rotation + (if point.r? then point.r else 0)

      @game.addObject proj
      @stats.shots_fired++
      wp.curammo--
    wp.firetimer = wp.firerate
    
  update: (delta) ->
    super delta

    if @status.curhp <= 0
      @last_damaged_by.stats.kills++ if @last_damaged_by?
      @stats.deaths++
      @isRemove = true
      if @proto.destroyed?.particle?
        particle = new SpaceDom.Particle @proto.destroyed.particle, @game
        particle.x = @x
        particle.y = @y
        @game.addParticle particle

    return if @isRemove

    @status.curhp += @status.hregen * delta if @status.hregen > 0
    @status.curhp = @status.maxhp if @status.curhp > @status.maxhp

    @status.shield += @status.sregen * delta if @status.sregen > 0
    @status.shield = @status.maxshield if @status.shield > @status.maxshield

    for wp in @status.weapons
      
      if wp.firetimer > 0
        wp.firetimer -= delta
        wp.firetimer = 0 if wp.firetimer <= 0

      wp.regentimer -= delta
      if wp.regentimer <= 0 and wp.regen > 0
        wp.regentimer = wp.regen
        wp.curammo++
        wp.curammo = wp.maxammo if wp.curammo > wp.maxammo      
    
  canCollide: (other) ->
    super other
    
  collide: (other) ->
    other.takeDamage? @

  takeDamage: (other) ->
    if other instanceof Ship
      @stats.damage_taken++
      other.stats.damage_dealt++
      @status.shield -= 1
      if @status.shield < 0
        @status.curhp += @status.shield
        @status.shield = 0
    else if other instanceof Projectile
      @stats.damage_taken += other.specs.damage
      other.ship?.stats.damage_dealt += other.specs.damage
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
    @last_damaged_by = other.ship or other

  switchWeapon: () ->
    return if @status.weapons.length is 0
    @status.curweapon++
    @status.curweapon %= @status.weapons.length