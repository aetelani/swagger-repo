const RapidAPI = require('rapidapi-connect');
const rapid = new RapidAPI(process.env.MOCK_USER, process.env.MOCK_KEY);

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
