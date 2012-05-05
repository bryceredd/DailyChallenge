TEST_DB = process.env.TEST_DB || 'mongodb://localhost:27017/test'

util = require 'util'
assert = require 'assert'
mongoose = require 'mongoose'
Challenge = require '../model/Challenge'
Model = require '../model/index'

generateChallenge = ->
  challenge = new Challenge
  tasks = ["Billy", "Bobby", "Sandy"].map (body) -> challenge.createTask {"placeholder": body}

  quote: "He who stands on toilet, is high on pot"
  quoteCredit: "Ping Pong Xao"
  imageUrl: "http://lorempixum.com/300/300"
  imageCredit: "(C) Photo Amigos"
  challenge: "Bring soda to 3 of your close friends"
  tasks: tasks


describe 'challenge tests', ->
  model = new Model TEST_DB
  model.connect()
  challenge = new Challenge
  item = generateChallenge()

  beforeEach (done) ->
    challenge.Model.collection.drop (err) ->
      tasks = ["Billy", "Bobby", "Sandy"].map (body) -> challenge.createTask {"placeholder": body}
      challenge.save item, done

  describe "reading a challenge", ->
    it 'should return a challenge', (done) ->
      challenge.findById item.id, (err, item) ->
        done()


