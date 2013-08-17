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
  
  manifest = [
    {id: 'base-fighter1', src: 'assets/base-fighter1.png'},
    {id: 'block1', src: 'assets/block1.png'},
    {id: 'base-enemy1', src: 'assets/base-enemy1.png'},
  ]
  
  preload = new createjs.LoadQueue()
  preload.addEventListener 'complete', doneLoading
  preload.addEventListener 'progress', updateLoading
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
  
updateLoading = ->
  messageField.text = "Loading #{preload.progress*100|0}%"
  stage.update()

doneLoading = ->
  messageField.text = "Loading complete"
  stage.update()
  watchClick()
  
watchClick = ->
  canvas.onclick = handleClick

handleClick = () ->
  canvas.onclick = null
  stage.removeChild messageField
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
  
init()
