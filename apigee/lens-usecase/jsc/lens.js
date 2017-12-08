function toHyphenHEX(hex) {
    var hyphenHEX = '';
    for(var i=0; i<hex.length; i=i+2) {
        if(i != 0) {
            hyphenHEX += '-';
        }
        hyphenHEX += hex.substring(i,i+2);
    }
    return hyphenHEX.toUpperCase();
}

function base64url(source) {
  // Encode in classical base64
  var encodedSource = CryptoJS.enc.Base64.stringify(source);
  // Remove padding equal characters
  encodedSource = encodedSource.replace(/=+$/, '');
  // Replace characters according to base64url specifications
  encodedSource = encodedSource.replace(/\+/g, '-');
  encodedSource = encodedSource.replace(/\//g, '_');
  return encodedSource;
}

function createRequestToken(username, password) {
    var _sha256 = crypto.getSHA256();
    _sha256.update(username) //salt
    _sha256.update(password)
    var hash = toHyphenHEX(_sha256.digest());
    
    var header = {
        alg: 'HS256',
        typ: 'JWT'
    };
    
    var payload = {
        prn: username,
        aud: 'https://lens.liaison.com/tep',
        iss: username
    };
    
    var stringifiedHeader = CryptoJS.enc.Utf8.parse(JSON.stringify(header));
    var encodedHeader = base64url(stringifiedHeader);
    
    var stringifiedData = CryptoJS.enc.Utf8.parse(JSON.stringify(payload));
    var encodedData = base64url(stringifiedData);
    
    var signature = encodedHeader + "." + encodedData;
    signature = CryptoJS.HmacSHA256(signature, password);
    signature = base64url(signature);
    
    var requestToken = encodedHeader + "." + encodedData + "." + signature;
    return requestToken;
}

function getAccessToken(host, port, username, password) {
    var requestToken = createRequestToken(username, password);

    var req = httpClient.get('https://' + host + ':' + port + '/api/1/token?req_token=' + requestToken);
    req.waitForComplete();
    
    if (req.isSuccess()) {
        var json = req.getResponse().content.asJSON;

        if (json.error) {
          throw new Error(json.error_description);
        }

        return json.access_token;
    } else if (req.isError()) {
        throw new Error(req.getError());
    }
}
