DB = process.env.DB || 'mongodb://localhost:27017/challenge'
PORT = process.env.PORT || 2300
URL = process.env.URL || 'http://localhost:2300/'

express = require 'express'
sys = require 'sys'
Model = require './model/index'
Challenge = require './model/Challenge'


createServer = ->

  model = new Model DB
  model.connect()
  challenge = new Challenge

  app = express.createServer()

  app.use express.static(__dirname + '/public')
  app.use express.bodyParser keepExtensions: true, uploadDir: __dirname + "/public/photos"

  app.disconnect = ->
      model.disconnect()

  app.post '/challenge', (req, res) ->
    post = req.body
    post.imageUrl = URL + req.files.file.path.split('/').slice(-2).join('/')
    post.imagePath = req.files.file.path.split("/").slice(-2).join "/"
    post.date = new Date req.date

    i = 1
    post.tasks = []
    while req.body['task'+ (i++)]?.length > 1
      post.tasks.push challenge.createTask placeholder: (req.body["task#{i}"])

    challenge.save post, (err, item) ->
      res.send err, 500 if err?
      res.send item

  app.get '/challenge/:id', (req, res) ->
    challenge.findById req.params.id, (err, item) ->
      res.send err, 500 if err?
      res.send item

  app.get  '/challenges', (req, res) ->
    challenge.findAll (err, items) ->
      res.send err, 500 if err?
      res.send items

  return app


if module == require.main
  app = createServer()
  app.listen PORT
  console.log "listening on port #{PORT}"
