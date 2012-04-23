TEST_DB = process.env.TEST_DB || 'mongodb://localhost:27017/test'

util = require 'util'
assert = require 'assert'
mongoose = require 'mongoose'
Challenge = require '../model/Challenge'
Model = require '../model/index'
ObjectId = mongoose.Types.ObjectId


describe 'challenge tests', ->
  model = new Model TEST_DB
  model.connect()
  challenge = new Challenge

  beforeEach (done) ->
    challenge.Model.collection.drop (err) ->
      tasks = ["Billy", "Bobby", "Sandy"].map (body) -> challenge.createTask {"placeholder":body}
      challenge.save {
        _id: "4f94ad05d0034d128a000005"
        quote: "He who stands on toilet, is high on pot"
        quoteCredit: "Ping Pong Xao"
        imageUrl: "http://lorempixum.com/300/300"
        imageCredit: "(C) Photo Amigos"
        challenge: "Bring soda to 3 of your close friends"
        challengeTasks: tasks
      }, done

  describe "reading a challenge", ->
    it 'should return a challenge', (done) ->
      id = new ObjectId "4f94ad05d0034d128a000005"
      challenge.findById id, (err, item) ->
        console.log item
        done()
