const RapidAPI = require('rapidapi-connect');
const rapid = new RapidAPI("default-application_5a1e9476e4b0d45349f770c8", "34430c20-a6a3-438e-9035-a9158498d424");

function withLocation(req, res) {
    var location = req.swagger.params.location.value;
    console.log('Calling YahooWeather API with location: '+ location);
    rapid.call('YahooWeatherAPI', 'getWeatherForecast', {
        'location': location
    })
    .on('success', (payload)=> {
        console.log('Returning YahooWeather API response');
        res.json(payload);
    }).on('error', (payload)=> {
        console.log('Error wetching data from YahooWeather API');
   });
}
