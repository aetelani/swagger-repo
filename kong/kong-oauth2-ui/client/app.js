// just for mocking workflow puproses.

var express    = require("express");
var request    = require('request');
//var bodyParser = require('body-parser');
var nJwt = require('njwt');
var secureRandom = require('secure-random');
var redisClass = require("redis");
const uuidv1 = require('uuid/v1');

const LISTEN_PORT = 3000;

const signingKey = secureRandom(256, {type: 'Buffer'});
 
const claims = {
	iss: "http://localhost:8000/poc",  // Service URL
	sub: "users/poc",    // The UID of the user
	scope: "user, admin" // Scopes
}

const app	= express();

app.set('view engine', 'pug');

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

	const REDIS_OPTIONS = {
		'host': 'poc-redis',
		'port': 6379,
		'db': 1 // Testing tenancy. Use unique db from namespace broker
	}
	const redis = redisClass.createClient(REDIS_OPTIONS);
	redis.on('connect', function() {
		console.log('redis connected');
		console.log(REDIS_OPTIONS)
	});

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

	redis.flushdb( function (err, succeeded) {
		console.log(succeeded);
	});
});

// Listener at LISTEN_PRT
app.listen(LISTEN_PORT);
