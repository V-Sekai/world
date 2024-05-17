const dgram = require('dgram');

const server = dgram.createSocket('udp4');

let playerStates = new Map();

server.on('message', (msg, rinfo) => {
  let playerId = parseInt(msg.slice(0, 4).toString());
  playerStates.set(playerId, rinfo);

  const client = dgram.createSocket('udp4');
  client.send(msg, 10000, 'localhost', (err) => {
    client.close();
  });
});

server.bind(8000);