mongoose = require 'mongoose'

class Model

  constructor: (@connection) ->
    console.log "making connection with #{@connection}"

  connect: => mongoose.connect @connection

  disconnect: => mongoose.disconnect

module.exports = Model
