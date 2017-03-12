'use strict';

// required modules
const http = require('http');



// module declareations

// this module calls TMS api movie playing in local theatra, pass zipcode and current date as parameters and fetch general data about movie that currentlly playing in local theaters, including showtime information.
module.exports.getLocalMovies = httpGetRequestTmsApi;

// this module calls TMDB api search/movie pass movie title and release year as parameters and fetch general data about the movie.
module.exports.getOneMovie = httpGetRequestTMDBSearchMovieApi;

// this module calls TMDB api movie/video pass imdb_id as parameter and fetch movie trailer data about movie.
module.exports.getTrailer = httpGetRequestTMDBMovieTrailerApi;



// requred constants
const TMDB_API_key = process.env.TMDB_API_key;
const Gracenote_API_key = process.env.Gracenote_API_key;

// implementation of modules
function httpGetRequestTmsApi (event, context, callback) {
  var d = new Date();
  var today = d.getFullYear() + '-' + (d.getMonth()+1) + '-' + d.getDate();
  let tms_params = {
    hostname : "data.tmsapi.com",
    path : "/v1.1/movies/showings?startDate=" + today + "&zip=47904&api_key=" + Gracenote_API_key
  };
  // http request
  let request = http.get(tms_params, (response) => {
    response.setEncoding('utf8');
    // process incomng JSON
    let rawData = '';
    response.on('data', function(chunk) {
        rawData += chunk;
    });
    response.on('end', function() {
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
