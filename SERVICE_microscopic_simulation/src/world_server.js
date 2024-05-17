const fs = require('fs');
const path = require('path');
const dgram = require('dgram');

class Node {
  constructor(state) {
    this.state = state;
    this.firstChild = null;
    this.nextSibling = null;
  }
}

let playerStates = new Map();

function convertDataToStates(data) {
  let states = [];
  for (let i = 0; i < data.length; i += 100) {
    states.push(data.slice(i, i + 100).toString());
  }

  if (states.length > 100) {
    states = states.slice(states.length - 100);
  }

  return states;
}

function convertStatesToTree(states) {
  let nodes = {};
  let root;

  for (let i = 0; i < states.length; i++) {
    nodes[i] = new Node(states[i]);
    if (i === 0) {
      root = nodes[i];
    } else {
      let parent = nodes[Math.floor((i - 1) / 2)];
      if (!parent.firstChild) {
        parent.firstChild = nodes[i];
      } else {
        let sibling = parent.firstChild;
        while (sibling.nextSibling) {
          sibling = sibling.nextSibling;
        }
        sibling.nextSibling = nodes[i];
      }
    }
  }

  return root;
}

function processTree(tree) {
  let result = '';
  function dfs(node) {
    if (!node) return;
    result += node.state;
    dfs(node.firstChild);
    dfs(node.nextSibling);
  }
  dfs(tree);
  return result;
}

function convertTreeToData(tree) {
  return Buffer.from(processTree(tree));
}

let playerStateFiles = fs.readdirSync('./');
let data = [];

playerStateFiles.forEach(file => {
  if (path.extname(file) === '.bin') {
    let fileData = fs.readFileSync(file);
    data.push(...convertDataToStates(fileData));
  }
});

let tree = convertStatesToTree(data);

let processedData = convertTreeToData(tree);

fs.writeFileSync('worldServer01.txt', processedData);

const server = dgram.createSocket('udp4');

server.on('message', (msg, rinfo) => {
  let playerId = parseInt(msg.slice(0, 4).toString());
  playerStates.set(playerId, rinfo);

  setInterval(() => {
    let playerRinfo = playerStates.get(playerId);
    if (playerRinfo) {
      server.send(processedData, playerRinfo.port, playerRinfo.address, (err) => {
        if (err) console.log(err);
      });
    }
  }, 1000);
});

server.bind(8000);