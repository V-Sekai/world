const fs = require('fs');
const dgram = require('dgram');
const server = dgram.createSocket('udp4');
const playerStateSize = 100;

let playerDataMap = new Map();

server.on('message', (msg, rinfo) => {
  let playerId = parseInt(msg.slice(0, 4).toString());
  const offset = playerId * playerStateSize;
  playerDataMap.set(rinfo, {playerId: playerId, offset: offset, data: msg});
  let buffer = Buffer.from(msg);
  fs.writeFile(`player_${playerId}.bin`, buffer, 'binary', (err) => {
    if(err) {
      console.log(err);
    } else {
      console.log(`The file was saved as player_${playerId}.bin!`);
    }
  });
});

server.bind(8000);