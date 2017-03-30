'use strict';

// this module calls TMDB api movie/video pass imdb_id as parameter and fetch movie trailer data about movie.
module.exports.handler = httpGetRequestTMDBMovieTrailerApi;



// required modules
const http = require('http');
// requred constants
const TMDB_API_key = process.env.TMDB_API_key;
// implementation
function httpGetRequestTMDBMovieTrailerApi(event, context, callback) {
  let tmdb_param = {
    hostname : "api.themoviedb.org",
    path : "/3/movie/" + event.id + "/videos?api_key=" + TMDB_API_key + "&language=en-US"
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
    //return error
    callback(error, null);
  });
}