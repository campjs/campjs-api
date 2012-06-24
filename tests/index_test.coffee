restify = require('restify')
app = require('../index')

assert = require('assert')

describe 'submitting user details to signup', ->
  TEST_DB = 4
  client = undefined
  db = undefined
  before () ->
    client = restify.createJsonClient
      url: 'http://localhost:3333'

    app.listen(3333)
    db = app.db
  beforeEach (done) ->
    db.flushdb(done)

  describe 'submitting email address', ->
    it 'responds with 200 & adds member', (done) ->
      email = 'secoif@gmail.com'
      client.post '/register', {details: email}, (err, req, res, obj) ->
        assert.ifError(err)
        assert.strictEqual(res.statusCode, 200)
        db.sismember 'emails', email, (err, result) ->
          assert.ifError(err)
          assert.ok(result)
          done()
  describe 'submitting email address twice', ->
    it 'responds with 200 & doesn\'t add member twice', (done) ->
      email = 'secoif@gmail.com'
      client.post '/register', {details: email}, (err, req, res, obj) ->
        assert.ifError(err)
        assert.strictEqual(res.statusCode, 200)
        client.post '/register', {details: email}, (err, req, res, obj) ->
          db.scard 'emails', (err, result) ->
            assert.ifError(err)
            assert.strictEqual(result, 1)
            done()

  describe 'submitting twitter address with leading @', ->
    it 'responds with 200 & adds member', (done) ->
      twitter = '@secoif'
      client.post '/register', {details: twitter}, (err, req, res, obj) ->
        assert.ifError(err)
        assert.strictEqual(res.statusCode, 200)
        db.sismember 'twitters', twitter.replace('@', ''), (err, result) ->
          assert.ifError(err)
          done()

  describe 'errors', ->
    assertAllEmpty = (done) ->
      db.scard 'emails', (err, result) ->
        assert.ifError(err)
        assert.strictEqual(result, 0)
        db.scard 'twitters', (err, result) ->
          assert.ifError(err)
          assert.strictEqual(result, 0)
          done()

    describe 'submitting no address', ->
      it 'responds with error code', (done) ->
        client.post '/register', {details: ''}, (err, req, res, obj) ->
          assert.ok(err)
          assert.strictEqual(res.statusCode, new restify.MissingParameterError().statusCode)
          assertAllEmpty(done)
    describe 'submitting garbage', ->
      it 'responds with error code', (done) ->
        client.post '/register', {details: '!#$%^&*SDIUYVB'}, (err, req, res, obj) ->
          assert.ok(err)
          assert.strictEqual(res.statusCode, 409)
          assertAllEmpty(done)
    describe 'submitting somewhat sensible garbage', ->
      it 'responds with error code', (done) ->
        client.post '/register', {details: 'asdfghjk'}, (err, req, res, obj) ->
          assert.ok(err)
          assert.strictEqual(res.statusCode, 409)
          assertAllEmpty(done)
    describe 'submitting nothing', ->
      it 'responds with error code', (done) ->
        client.post '/register', {}, (err, req, res, obj) ->
          assert.ok(err)
          assert.strictEqual(res.statusCode, 409)
          assertAllEmpty(done)


