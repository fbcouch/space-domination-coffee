# Space Domination
# (c) 2013 Jami Couch
# Source is released under Apache License v2.0
# ahsgaming.com

root = this

canvas = {}
stage = {}
canvasWidth = canvasHeight = 0

init = ->
  console.log 'game init'
  
  canvas = document.getElementById 'gameCanvas'
  canvas.style.background = '#000'
  stage = new createjs.Stage canvas
  
  # make the game take the entire browser window
  canvasWidth = canvas.width = document.documentElement.clientWidth
  canvasHeight = canvas.height = document.documentElement.clientHeight
  
  console.log canvasWidth
  messageField = new createjs.Text 'Hello, Coffee!', 'bold 30px sans-serif', '#CCC'
  messageField.textAlign = 'center'
  messageField.x = canvasWidth / 2
  messageField.y = canvasHeight / 2

  stage.addChild messageField
  stage.update()
  
init()
