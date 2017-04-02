'use strict';

// invoke getLocalMovies and update movie_table
module.exports.handler = invokeGetLocalMoviesAndUpdateMovieTable;


const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function invokeGetLocalMoviesAndUpdateMovieTable (event, context, callback) {
	getLocalMovies(() => {
		callback(null, "success");
	})
}


function getLocalMovies(callback) {
	let tms_params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getLocalMovies-dev",
		InvocationType: "RequestResponse"
	};
	//invoke function to get tms data
	lambda.invoke(tms_params, function localMovieResponse(err, data) {
		if (err) 
			console.error(err, null);
		else  {
			console.log("----- get TMS data, about to updateLocalMovieInfo()");
			//console.log(data.Payload);
			updateLocalMovieInfo(JSON.parse(data.Payload), () => {
				callback();
			});
		}   		
	});
}


function updateLocalMovieInfo(Payload, callback) {
	var length = Payload.length;
	for (var i = 0; i < length; i++) {

		if (Payload[i].subType != "Feature Film")
			continue;

		var title = Payload[i].title;
        title = title.replace(/ 3D/g, ""); // remove tailing " 3D" from movie title
		var shortDescription = Payload[i].shortDescription;
		var longDescription = Payload[i].longDescription;
		var releaseYear = Payload[i].releaseYear.toString();
		var genres = Payload[i].genres;
		var topCast = Payload[i].topCast;
		var directors = Payload[i].directors;

		//titleToReleaseYear.set(title, releaseYear);

		//console.log("added <" + title + "> to Map");

		var params = {
			Key: {
                "title": {
                    S: title
                }
            },
            ExpressionAttributeNames: {
                "#shortDescription": "shortDescription",
                "#longDescription": "longDescription",
                "#genres": "genres",
                "#topCast": "topCast",
                "#directors": "directors",
                "#isHistory": "isHistory",
                "#releaseYear": "releaseYear"
            },
            ExpressionAttributeValues: {
                ":shortDescription": {
                    S: shortDescription
                },
                ":longDescription": {
                    S: longDescription
                },
                ":releaseYear": {
                	S: releaseYear
                },
                ":genres": {
                	SS: genres
                },
                ":topCast": {
                	SS: topCast
                },
                ":directors": {
                	SS: directors
                },
                ":isHistory": {
                    BOOL: false
                }
            },
            ReturnValues: "ALL_NEW",
            TableName: "movie_table",
           	UpdateExpression: "SET #releaseYear = :releaseYear, #shortDescription = :shortDescription, #longDescription = :longDescription, #genres = :genres, #topCast = :topCast, #directors = :directors, #isHistory = :isHistory" 
		};
		dynamoDB.updateItem(params, function(err, data) {
            if (err) console.log(err, err.stack); // an error occurred
            else
            	console.log("updateLocalMovieInfo success"); 
        });
	}
	callback();
}