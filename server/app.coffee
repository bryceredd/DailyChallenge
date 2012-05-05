DB = process.env.DB || 'mongodb://localhost:27017/challenge'
PORT = process.env.PORT || 2300

express = require 'express'
Model = require './model/index'
Challenge = require './model/Challenge'


createServer = ->

  model = new Model DB
  model.connect()
  challenge = new Challenge

  app = express.createServer()

  app.disconnect = ->
      model.disconnect()

  app.post '/challenge', (req, res) ->
    item = challenge req.body (err) ->
      res.send err, 500 if err?
      res.send {}

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
