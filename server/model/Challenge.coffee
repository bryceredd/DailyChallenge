mongoose = require 'mongoose'
Schema = mongoose.Schema
util = require 'util'

class Challenge 

  constructor: ->

    ChallengeTaskSchema = new Schema {
      placeholder: String
    }

    ChallengeSchema = new Schema {
      date: {type: Date, default: Date.now}
      quote: String
      quoteCredit: String
      imageUrl: String
      imageCredit: String
      challenge: String
      challengeTasks: [ChallengeTaskSchema]
    }
    
    mongoose.model "Challenge", ChallengeSchema
    mongoose.model "ChallengeTask", ChallengeTaskSchema

    @Model = mongoose.model "Challenge"
    @TaskModel = mongoose.model "ChallengeTask"

  findById: (id, cb) =>
    @Model.findById id, cb

  save: (body, cb) =>
    challenge = new @Model body
    challenge.save cb
    return challenge

  createTask: (body, cb) =>
    new @TaskModel body
  


module.exports = Challenge
