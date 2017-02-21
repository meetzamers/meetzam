'use strict';
const http = require('http');
const TMDB_API_key = process.env.TMDB_API_key;
const Gracenote_API_key = process.env.Gracenote_API_key;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

// find the handler here
module.exports.handler = (event, context, callback) => {
 let param = {
   hostname : "api.themoviedb.org",
   path : "/3/movie/now_playing?api_key=" + TMDB_API_key + "&language=en-US&page=1"
 };

 // http request

 let request = http.get(param, function(response) {
   response.setEncoding('utf8');

   // process incomng JSON

   let rawData = '';

   response.on('data', function(chunk) {
       rawData += chunk;
   });


   response.on('end', function() {
     let parsedData = JSON.parse(rawData);
     //console.log("Fetched JSON is: " + JSON.stringify(parsedData));
     putMoviesToDBTable(parsedData);
   });

 });

 request.on('error', function(error) {
   console.error('HTTP error' + error.message);
   callback(error);
 });


};

// helper functions here
function putMoviesToDBTable(parsedData)
{
     let results = parsedData["results"];
     var len=results.length;
     for (var i=0;i<len;i++)
     {
         let TMDB_id = results[i]["id"];
         console.log("TMDB_id is "+TMDB_id);
         let title = results[i]["title"];
         console.log("title is "+title);
         let popularity = results[i]["popularity"];
         console.log("popularity is "+popularity);
         let release_date = results[i]["release_date"];
         console.log("release_date is "+release_date);

         var params =
          {
           Item: {
             "userId":{
                S: TMDB_id.toString()
             },
             "Title": {
               S: title
              },
             "TMDB_popularity": {  
               S: popularity.toString()
             },
             "release_date" : {
               S: release_date
             }
           },
           ReturnConsumedCapacity: "TOTAL",
           TableName: "meetzam-mobilehub-1569925313-Movie"
          };
           dynamoDB.putItem(params, function(err, data) {
             if (err) console.log(err, err.stack); // an error occurred
              else     console.log(data);           // successful response
            /*
             data = {
             ConsumedCapacity: {
             CapacityUnits: 1,
             TableName: "meetzam-mobilehub-1569925313-Movie"
             }
            }
            */
          });
     }
}