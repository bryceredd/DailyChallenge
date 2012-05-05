mongoose = require 'mongoose'
Schema = mongoose.Schema
util = require 'util'


class Challenge

  constructor: () ->

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
      tasks: [ChallengeTaskSchema]
    }

    @Model = mongoose.model "Challenge", ChallengeSchema
    @TaskModel = mongoose.model "ChallengeTask", ChallengeTaskSchema

  findById: (id, cb) => @Model.findById id, cb

  findAll: (cb) =>
    @Model.find {}, cb

  save: (body, cb) =>
    challenge = new @Model body
    challenge.save cb
    return challenge

  createTask: (body, cb) =>
    new @TaskModel body

  tagletFromTag: (tag) =>


module.exports = Challenge

