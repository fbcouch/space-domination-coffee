# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

window.SpaceDom or= {}

window.SpaceDom.ProfileScreen = class ProfileScreen extends SpaceDom.Screen

  constructor: (@preload, @game) ->
    super @preload, @game

  resize: (@width, @height) ->
    super @width, @height

    profiles = @game.listPilots()

    selectMenu = new SpaceDom.TextMenu ({text: profile.name, profile: id} for id, profile of profiles), null, (item) =>
      console.log item.profile

    selectMenu.x = (@width - selectMenu.width) * 0.5
    selectMenu.y = (@height - selectMenu.height) * 0.5

#    @addChild selectMenu

    @newProfileMenu = new SpaceDom.UpdateContainer()

    nameLabel = new createjs.Text "Enter your callsign: ", "bold 24px Courier", "#FFFFFF"
    @newProfileMenu.addChild nameLabel

    @nameInput = new SpaceDom.TextInput ""
    @nameInput.x = nameLabel.getBounds().width
    @newProfileMenu.addChild @nameInput

    {width: @newProfileMenu.width, height: @newProfileMenu.height} = @newProfileMenu.getBounds()

    @newProfileMenu.x = (@width - @newProfileMenu.width) * 0.5
    @newProfileMenu.y = (@height - @newProfileMenu.height) * 0.5
    @addChild @newProfileMenu

    window.addEventListener 'keydown', (e) =>
      e or= window.event
      @nameInput.keydown? e

  update: (delta, keys) ->
    super delta, keys

    if not @first_pass_done?
      @first_pass_done = true
      keys[key] = false for key of keys

    child.update? delta, keys for child in @children


