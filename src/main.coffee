# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

root = this

SpaceDominationGame = root.SpaceDom.SpaceDominationGame

KEYCODE_ENTER = 13
KEYCODE_SPACE = 32
KEYCODE_SHIFT = 16
KEYCODE_CTRL = 17
KEYCODE_UP = 38
KEYCODE_LEFT = 37
KEYCODE_RIGHT = 39
KEYCODE_DOWN = 40
KEYCODE_W = 87
KEYCODE_A = 65
KEYCODE_D = 68
KEYCODE_S = 83
KEYCODE_0 = 48

keys = {}
  
keyMap =
  accel: [KEYCODE_W, KEYCODE_UP]
  brake: [KEYCODE_S, KEYCODE_DOWN]
  left: [KEYCODE_A, KEYCODE_LEFT]
  right: [KEYCODE_D, KEYCODE_RIGHT]
  fire: [KEYCODE_SPACE]
  pause: [KEYCODE_ENTER]

canvas = {}
stage = {}
canvasWidth = canvasHeight = 0
preload = {}
progressbar = {}
messageField = {}
game = {}

init = ->
  console.log 'game init'
  
  canvas = document.getElementById 'gameCanvas'
  canvas.style.background = '#000'
  stage = new createjs.Stage canvas
  
  # make the game take the entire browser window
  canvasWidth = canvas.width = document.documentElement.clientWidth
  canvasHeight = canvas.height = document.documentElement.clientHeight
  
  # create a progress bar
  messageField = new createjs.Text 'Loading', 'bold 30px sans-serif', '#CCC'
  messageField.textAlign = 'center'
  messageField.x = canvasWidth / 2
  messageField.y = canvasHeight / 2
  
  stage.addChild messageField
  stage.update()

  # JC: Preloading asset definitions and then all images
  manifest = [
    {id: 'shiplist', src: 'assets/ships.json'},
    {id: 'particles', src: 'assets/particles.json'},
    {id: 'missions', src: 'assets/missions.json'}
  ]

  other = [
    {id: 'bg-menu', src: 'assets/bg-menu.png'}
  ]
  
  preload = new createjs.LoadQueue()
  preload.addEventListener 'complete', ->
    missions = ({id: mission, src: "assets/missions/#{mission}.json"} for mission in preload.getResult 'missions')
    preload.removeAllEventListeners 'complete'
    preload.addEventListener 'complete', ->
      images = []
      images.push {id: image, src: "assets/#{image}.png"} for image in gather_images(preload.getResult item.id) for item in manifest
      images.push {id: image, src: "assets/#{image}.png"} for image in gather_images(preload.getResult item.id) for item in missions
      images.push item for item in other

      preload.removeAllEventListeners 'complete'
      preload.addEventListener 'complete', doneLoading
      preload.addEventListener 'progress', updateLoading
      preload.loadManifest images
    preload.loadManifest missions
  preload.loadManifest manifest
  
  # add exports to the root
  root.canvas = canvas
  root.stage = stage
  root.preload = preload
  
  document.onkeydown = handleKeyDown
  document.onkeyup = handleKeyUp
  
  window.onresize = (event) ->
    canvasWidth = canvas.width = document.documentElement.clientWidth
    canvasHeight = canvas.height = document.documentElement.clientHeight
    stage.update()
    game?.resize()
  
gather_images = (obj) ->
  images = []
  for key, val of obj
    if key is 'image'
      images.push val
    else if key is 'images'
      images.push img for img in val
    else if typeof val is 'object'
      images.push image for image in gather_images val
  images

updateLoading = ->
  messageField.text = "Loading #{preload.progress*100|0}%"
  stage.update()

doneLoading = ->
  messageField.text = "Loading complete"
  stage.removeAllChildren()
  stage.update()
  start()
  
handleKeyDown = (e) ->
  e or= window.event
  (keys[key] = true if e.keyCode in keyMap[key]) for key of keyMap
  false
  
handleKeyUp = (e) ->
  e or= window.event
  (keys[key] = false if e.keyCode in keyMap[key]) for key of keyMap
  false
  
start = () ->
  console.log 'Start game...'
  game = new SpaceDominationGame stage, canvas, preload
  createjs.Ticker.addEventListener('tick', tick) if not createjs.Ticker.hasEventListener('tick')
  createjs.Ticker.setFPS 30
  
tick = (event) ->
  delta = event.delta / 1000
  return if not event.delta?
  
  # update things
  game.update delta, keys
  stage.update()

window.SpaceDom.UpdateContainer = class UpdateContainer extends createjs.Container
  constructor: () ->
    super()
    @initialize()

  update: (delta, keys) ->
    child.update? delta, keys for child in @children

init()