'use strict';

// Author: Rick Baker <rick@ricktbaker.com>

const Hapi = require('hapi');

const server = new Hapi.Server();
server.connection({
  host : '0.0.0.0',
  port : 3000,
  routes : {
    cors : true,
    log : true
  }
});


// Start the server
server.start(function() {
  server.log('info', 'Server running at: ' + server.info.uri);
});

// Basic route
server.route({
  method: 'GET',
  path: '/',
  handler: function (request, reply) {
    reply('Hello, world!');
  }
});

