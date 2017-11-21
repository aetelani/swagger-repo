// just for mocking workflow puproses.

const express    = require("express");
const request    = require('request');
const BSON = require('bson'); // Native api would be nice
//const bodyParser = require('body-parser');
const bearerToken = require('express-bearer-token');
const nJwt = require('njwt');
const secureRandom = require('secure-random');
const redisClass = require("redis");
const uuidv1 = require('uuid/v1');

const REDIS_OPTIONS = {
	'host': 'poc-redis',
	'port': 6379,
	'db': 1 // Only for mocking purposes
}

const LISTEN_PORT = 3000;

const app	= express();

var bson = new BSON();

app.set('view engine', 'pug');

app.use(bearerToken());

// Accept every SSL certificate
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// Index page
app.get("/", function(req, res) {
  res.render('index');
});


// send JWT to poc api and pipe result back
app.get("/send-jwt", function(req, res) {
	console.log('got request /send-jwt');

	const redis = redisClass.createClient(REDIS_OPTIONS);
	redis.on('connect', function() {
		console.log('redis connected');
		console.log(REDIS_OPTIONS)
	});

	const claims = {
		iss: "http://localhost:8000/poc",  // Service URL
		sub: "users/poc",    // The UID of the user
		scope: "user, admin" // Scopes
	}
	
	const signingKey = secureRandom(256, {type: 'Buffer'});

	var jwt = nJwt.create(claims, signingKey);

	console.log(jwt);

	var token = jwt.compact();

	console.log(token);
	
	// Put jwt object to token key
	redis.hmset(token, 'claims', bson.serialize(claims), 'key', signingKey);

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
