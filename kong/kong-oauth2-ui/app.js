// just for mocking workflow puproses.

var request    = require('request');
var url        = require('url');
var bodyParser = require('body-parser');
var express    = require("express");
var app        = express();

app.set('view engine', 'jade');
app.use(bodyParser());

// Accept every SSL certificate
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

function load_env_variable(name) {
  var value = process.env[name];
  if (value) {
    console.log(name + " is " + value);
    return value;
  } else {
    console.error("You need to specify a value for the environment variable: " + name);
    process.exit(1);
  }
}

/*
  This is the secret provision key that the plugin has generated
  after being added to the API
*/
var PROVISION_KEY = load_env_variable("PROVISION_KEY");

/*
  Client credentials from env
*/
var CLIENT_ID = load_env_variable("CLIENT_ID");
var CLIENT_SECRET = load_env_variable("CLIENT_SECRET");

/*
  Redirect Address from env
*/
var REDIRECT_ADDRESS = load_env_variable("REDIRECT_ADDRESS");

/*
  URLs to Kong
*/
var KONG_ADMIN = load_env_variable("KONG_ADMIN");
var KONG_API = load_env_variable("KONG_API");

/*
  The path to the API, required later when making a request
  to authorize the OAuth 2.0 client application
*/
var API_PATH = load_env_variable("API_PATH");

/* 
  The scopes that we support, with their extended
  description for a nicer frontend user experience
*/
var SCOPE_DESCRIPTIONS = JSON.parse(load_env_variable("SCOPES"));

/* 
  The port the authorization server listens on. Defaults to 3000.
*/
var LISTEN_PORT = process.env["LISTEN_PORT"] || 3000

/*
  Retrieves the OAuth 2.0 client application name from
  a given client_id - used for a nicer fronted experience
*/
function get_application_name(client_id, callback) {
  request({
    method: "GET",
    url: KONG_ADMIN + "/oauth2",
    qs: { client_id: client_id }
  }, function(error, response, body) {
    var application_name;
    if (client_id && !error) {
      var json_response = JSON.parse(body);
      if (json_response.data.length == 1) {
        application_name = json_response.data[0].name;
      }
    }
    callback(application_name);
  });
}

/*
  The POST request to Kong that will actually try to
  authorize the OAuth 2.0 client application after the
  user submits the form
*/
function authorize(client_id, response_type, scope, callback) {
  request({
    method: "POST",
    url: KONG_API + API_PATH + "/oauth2/authorize",
	  form: { 
      client_id: client_id, 
      response_type: response_type, 
      scope: scope, 
      provision_key: PROVISION_KEY,
      authenticated_userid: "userid123" // Hard-coding this value (it should be the logged-in user ID)
    }
  }, function(error, response, body) {
	  console.log("error:"); console.log(error);
//	  console.log("response:"); console.log(response);
	  console.log("body:"); console.log(body);
    callback(JSON.parse(body).redirect_uri);
  });
}

/*
  The route that shows the authorization page
*/
app.get('/authorize', function(req, res) {
  var querystring = url.parse(req.url, true).query;
  get_application_name(querystring.client_id, function(application_name) {
    if (application_name) {
      res.render('authorization', { 
        client_id: querystring.client_id,
        response_type: querystring.response_type,
        scope: querystring.scope,
        application_name: application_name,
        SCOPE_DESCRIPTIONS: SCOPE_DESCRIPTIONS 
      });
    } else {
      res.status(403).send("Invalid client_id");
    }
  });
});

/*
  The route that handles the form submit, that will
  authorize the client application and redirect the user
*/
app.post('/authorize', function(req, res) {
  authorize(req.body.client_id, req.body.response_type, req.body.scope, function(redirect_uri) {
    res.redirect(redirect_uri);
  });
});

/*
  Index page
*/

app.get("/", function(req, res) {
  res.render('index');
});

/*
  Client
  get access token
 */
app.get("/access-token", function(req, res) {
  const requestCode = req.query.code;
  console.log("code:" + requestCode);
  // do post here with code
  if (!!requestCode) {
	  res.send("code found: " + requestCode);
	   const theRequest = {
		   url: 'https://127.0.0.1:8443/poc/oauth2/token',
		   form : {
			   grant_type: 'authorization_code',
			   client_id: CLIENT_ID,
			   client_secret: CLIENT_SECRET,
			   redirect_uri: REDIRECT_ADDRESS,
			   code: requestCode
		   }};
	   request.post(theRequest,
		function (error, response, body) {
           if (!error && response.statusCode == 200) {
             console.log(body) // Print the body
           } else {
			   console.log(error);
			   console.log(body);
			   //console.log(response);
		   }
	})
  } else {
	  res.status(400).send("Code NOT found");
  }
});

app.listen(LISTEN_PORT);

console.log("Running at Port " + LISTEN_PORT);
