http = require('http')
path = require('path')

async = require('async')
socketio = require('socket.io')
express = require('express')

# ## SimpleServer `SimpleServer(obj)`
# Creates a new instance of SimpleServer with the following options:
#  * `port` - The HTTP port to listen on. If `process.env.PORT` is set, _it overrides this value_.
router = express()
server = http.createServer(router)
io = socketio.listen(server)

router.use(express.static(path.resolve(__dirname, '../client')))
messages = []
sockets = []

io.on 'connection', (socket) ->
    messages.forEach (data) ->
      socket.emit('message', data)

    sockets.push(socket)

    socket.on 'disconnect', () ->
      sockets.splice(sockets.indexOf(socket), 1)

    socket.on 'message', (msg) ->
      return unless msg
      text = String(msg)
      console.log "socket.on 'message', ", text

broadcast = (event, data) ->
  sockets.forEach (socket) ->
    socket.emit(event, data)

server.listen (process.env.PORT || 3000), (process.env.IP || "0.0.0.0"), ->
  addr = server.address()
  console.log("Chat server listening at", addr.address + ":" + addr.port)
