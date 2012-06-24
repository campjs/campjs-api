redis = require('redis')
restify = require('restify')

sanitize = require('validator').sanitize

if process.env['NODE_ENV'] == 'production'
  port = process.env['REDIS_PORT']
  host = process.env['REDIS_HOST']
  db = redis.createClient(port, host)
  db.auth process.env['REDIS_PASSWORD'], (err, status) ->
    if (err || status != 'OK')
      throw new Error(err)
    console.info('Connected to redis!')
else
  console.info('connecting to local redis instance')
  db = redis.createClient()

app = restify.createServer()
app.use restify.queryParser()
app.use restify.bodyParser()
app.use restify.acceptParser(app.acceptable)

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
