redis = require('redis')
restify = require('restify')

sanitize = require('validator').sanitize

db = redis.createClient()

app = restify.createServer()
app.use restify.queryParser()
app.use restify.bodyParser()
app.use restify.acceptParser(app.acceptable)

app.post '/register', (req, res) ->
app.post '/register', (req, res, next) ->
  userDetails = sanitize(req.params?.details || '').xss().trim()
  if not userDetails?
    return res.send(new restify.InvalidContentError())
  if /^(.+)@(.+)$/.test(userDetails)
    db.sadd "emails", userDetails, (err, result) ->
      if (err)
        return next(new restify.InternalError())
      console.info('Added email:', userDetails)
      return res.send(200)

  else if /^@[A-Za-z0-9-_]+$/.test(userDetails)
    db.sadd "twitters", userDetails, (err, result) ->
      if (err)
        return next(new restify.InternalError())
      console.info('Added email:', userDetails)
      return res.send(200)
  else
    console.info('Didn\'t handle:', userDetails)
    return next(new restify.MissingParameterError())

module.exports = app
app.db = db
