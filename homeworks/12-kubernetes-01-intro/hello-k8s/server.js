var http = require('http');
var handleRequest = function(request, response) {
  console.log('Req URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello k8s Beginners!');
};
var helloServer = http.createServer(handleRequest);
helloServer.listen(8080);
