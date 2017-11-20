// just for mocking workflow puproses.

var request    = require('request');
//var bodyParser = require('body-parser');
var nJwt = require('njwt');
var secureRandom = require('secure-random');
var express    = require("express");
var redisClass = require("redis");

const LISTEN_PORT = 3000;

const redis = redisClass.createClient(6379, 'poc-redis');

const app	= express();

app.set('view engine', 'pug');

const signingKey = secureRandom(256, {type: 'Buffer'});

const claims = {
  iss: "http://localhost:8000/poc",  // Service URL
  sub: "users/poc",    // The UID of the user
  scope: "user, admin" // Scopes
}

var jwt = nJwt.create(claims,signingKey);


// Accept every SSL certificate
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// Index page
app.get("/", function(req, res) {
  res.render('index');
});


// send JWT to poc api and pipe result back
app.get("/send-jwt", function(req, res) {
	console.log('got request /send-jwt');
	request({
//		uri: "http://localhost:8000/poc",
		uri: "http://mockbin.org/request",
		headers: {
			'Hosts': 'poc',
		}
	},	function (error, response, body) {
			console.log('error:', error);
			console.log('statusCode:', response && response.statusCode);
			console.log('body:', body);
	}).pipe(res);
});

// Listener at LISTEN_PRT
app.listen(LISTEN_PORT);
