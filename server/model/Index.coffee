mongoose = require 'mongoose'

class Model

  constructor: (@connection) ->

  connect: => mongoose.connect @connection

  disconnect: => mongoose.disconnect

module.exports = Model
