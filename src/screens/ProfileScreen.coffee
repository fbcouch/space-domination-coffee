# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.ProfileScreen = class ProfileScreen extends SpaceDom.Screen

  constructor: (@preload, @game) ->
    super @preload, @game

    @newProfileMenu = new SpaceDom.UpdateContainer()

    nameLabel = new createjs.Text "Enter your callsign: ", "bold 24px Courier", "#FFFFFF"
    @newProfileMenu.addChild nameLabel

    @nameInput = new SpaceDom.TextInput ""
    @nameInput.x = nameLabel.getBounds().width

    @nameInput.eventListener = (e) =>
      e or= window.event
      @nameInput.keydown? e

    @newProfileMenu.addChild @nameInput

    @new_profile_mode = false

  show: ->
    super()
    @layout()

  layout: ->
    @removeAllChildren()
    if @new_profile_mode
      {width: @newProfileMenu.width, height: @newProfileMenu.height} = @newProfileMenu.getBounds()

      @newProfileMenu.x = (@width - @newProfileMenu.width) * 0.5
      @newProfileMenu.y = (@height - @newProfileMenu.height) * 0.5

      window.addEventListener 'keydown', @nameInput?.eventListener

      @addChild @newProfileMenu
    else
      profiles = @game.listPilots()
      if profiles.length is 0
        @new_profile_mode = true
        @layout()
        return

      items = ({text: @game.loadPilot(id)['name'], profile: id} for id in profiles)
      items.push {text: 'New pilot', profile: -1}
      @selectMenu = new SpaceDom.TextMenu items, null, (item) =>
        if item.profile is -1
          @new_profile_mode = true
          @layout()
        else
          # load this profile!
          @game.loadPilot item.profile
          @game.setMenuScreen()

      @addChild @selectMenu
      @selectMenu.x = (@width - @selectMenu.width) * 0.5
      @selectMenu.y = (@height - @selectMenu.height) * 0.5

      window.removeEventListener 'keydown', @nameInput?.eventListener

  resize: (@width, @height) ->
    super @width, @height

    @layout()

  update: (delta, keys) ->
    super delta, keys

    if not @first_pass_done?
      @first_pass_done = true
      keys[key] = false for key of keys
      @fire_key_down = true

    if keys['fire'] and not @fire_key_down
      @fire_key_down = true
      if @new_profile_mode
        # add new profiles
        if @nameInput.text isnt '' and @nameInput.text not in @game.listPilots()
          @game.savePilot @nameInput.text, { name: @nameInput.text }
          # load this profile
          @game.loadPilot @nameInput.text
          @game.setMenuScreen()
    else if not keys['fire']
      @fire_key_down = false

    if keys['pause'] and not @pause_key_down
      @pause_key_down = true
      if @new_profile_mode
        @new_profile_mode = false
        @layout()
    else if not keys['pause']
      @pause_key_down = false

    child.update? delta, keys for child in @children

  hide: ->
    window.removeEventListener 'keydown', @nameInput.eventListener


