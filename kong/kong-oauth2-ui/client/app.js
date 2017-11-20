// just for mocking workflow puproses.

//var request    = require('request');
//var url        = require('url');
//var bodyParser = require('body-parser');
var express    = require("express");

const app        = express();
const LISTEN_PORT = 3000;

app.set('view engine', 'pug');


// Accept every SSL certificate
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// Index page
app.get("/", function(req, res) {
  res.render('index');
});

// Listener at LISTEN_PRT
app.listen(LISTEN_PORT);
