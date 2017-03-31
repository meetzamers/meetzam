'use strict';

// this module calls TMDB api search/movie pass movie title and release year as parameters and fetch general data about the movie.
module.exports.handler = httpGetRequestTMDBSearchMovieApi;



// required modules
const http = require('http');
// requred constants
const TMDB_API_key = process.env.TMDB_API_key;
// implementation
function httpGetRequestTMDBSearchMovieApi(event, context, callback) {
  var date = new Date();
  let tmdb_param = {
    hostname : "api.themoviedb.org",
    path : "/3/search/movie?api_key=" + TMDB_API_key + "&language=en-US&page=1&query=" + event.title + "&year=" + event.year 
  };
  // http request
  let request = http.get(tmdb_param, (response) => {
    response.setEncoding('utf8');
    // process incomng JSON
    let rawData = '';
    response.on('data', (chunk) => {
      rawData += chunk;
    });
    response.on('end', () => {
      let parsedData = JSON.parse(rawData);
      // return parsedData
      callback(null, parsedData);
    });
  });

  request.on('error', (error) => {
    console.error('HTTP error' + error.message);
    callback(error, null);
  });
}





