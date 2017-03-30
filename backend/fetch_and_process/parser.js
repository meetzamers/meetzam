'use strict';
const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

// map title to releaseYear
var titleToReleaseYear = new Map();

module.exports.updateMovieTable = (event, context, callback) => {
	getLocalMovies(() => {
		thenGetTMDBMovies(() => {
			invokeIdLessMovieDeletion(() => {
				callback(null, "seccess");
			})
		});
	});
};

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
				console.log("----- getLocalMovies is about to callback!!");
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
		var shortDescription = Payload[i].shortDescription;
		var longDescription = Payload[i].longDescription;
		var releaseYear = Payload[i].releaseYear.toString();
		var genres = Payload[i].genres;
		var topCast = Payload[i].topCast;
		var directors = Payload[i].directors;

		titleToReleaseYear.set(title, releaseYear);

		console.log("added <" + title + "> to Map");

		var params = {
			Key: {
                "title": {
                    S: title
                }
            },
            ExpressionAttributeNames: {
                "#shortDescription": "shortDescriptiontle",
                "#longDescription": "longDescription",
                "#genres": "genres",
                "#topCast": "topCast",
                "#directors": "directors",
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
                }
            },
            ReturnValues: "ALL_NEW",
            TableName: "movie_table",
           	UpdateExpression: "SET #releaseYear = :releaseYear, #shortDescription = :shortDescription, #longDescription = :longDescription, #genres = :genres, #topCast = :topCast, #directors = :directors" 
		};
		dynamoDB.updateItem(params, function(err, data) {
            if (err) console.log(err, err.stack); // an error occurred
            else
            	console.log("updateLocalMovieInfo success"); 
        });
	}
	callback();
}


function thenGetTMDBMovies(callback) {
	titleToReleaseYear.forEach(invokeMovieGetter);
	console.log("----- thenGetTMDBMovies is about to callback!!");
	callback();
}

function invokeMovieGetter(value, key, map) {
	var title = key.replace(/\ /g, "%20");
	var year = value.toString();
	console.log("invokeMovieGetter: " + title);
	let payload = {
		"title": title,
		"year": year
	};
	let tmdb_params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getOneMovie-dev",
		InvocationType: "RequestResponse",
		Payload: JSON.stringify(payload)
	};
	//invoke function to get tmdb data
	lambda.invoke(tmdb_params, (err, data) => {
		if (err) {
			console.error(err, null);
		}
		else {	
			//console.log("payload = " + data.Payload);
			updateOneMovieInMovieTable(title.replace(/\%20/g, " "), JSON.parse(data.Payload));
		}     
	});
} 

function updateOneMovieInMovieTable(title, Payload) {
	var total = Payload.total_results;
	var results = Payload.results;
	if (total > 0) {
		var tmdb_id = results[0].id.toString();
		var poster_path = results[0].poster_path;

		invokeTrailerGetter(title, tmdb_id);

		var params = {
			Key: {
            	"title": {
                	S: title
            	}
        	},
        	ExpressionAttributeNames: {
                "#tmdb_id": "tmdb_id",
                "#poster_path": "poster_path"
        	},
        	ExpressionAttributeValues: {
                ":tmdb_id": {
                	S: tmdb_id
                },
                ":poster_path": {
                	S: poster_path
                }
        	},
        	ReturnValues: "ALL_NEW",
        	TableName: "movie_table",
      	 	UpdateExpression: "SET #tmdb_id = :tmdb_id, #poster_path = :poster_path" 
		};
		dynamoDB.updateItem(params, function(err, data) {
            if (err) console.log(err, err.stack); // an error occurred
            else   
            	console.log("updateOneMovieInMovieTable success"); 
    	});
	}
}


function invokeTrailerGetter(title, id) {
	console.log("==== Trailer: " + id);
	let payload = {
		"id": id
	};
	let tmdb_params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getTrailer-dev",
		InvocationType: "RequestResponse",
		Payload: JSON.stringify(payload)
	};
	//invoke function to get tmdb data
	lambda.invoke(tmdb_params, (err, data) => {
		if (err) 
			console.error(err, null);
		else {
			console.log(data.Payload);
			//update function call
			updateOneTrailer(title, JSON.parse(data.Payload));
		}     
	});
}

function updateOneTrailer(title, Payload) {

	var results = Payload.results;
	var len = results.length;

	for (var i = 0; i < len; i++) {
		if (results[i].type == "Trailer" && results[i].site == "YouTube") {
			var trailer_key = results[i].key;

			var params = {
				Key: {
	            	"title": {
	                	S: title
	            	}
	        	},
	        	ExpressionAttributeNames: {
	                "#trailer_key": "trailer_key"
	        	},
	        	ExpressionAttributeValues: {
	                ":trailer_key": {
	                	S: trailer_key
	                }
	        	},
	        	ReturnValues: "ALL_NEW",
	        	TableName: "movie_table",
	      	 	UpdateExpression: "SET #trailer_key = :trailer_key" 
			};
			dynamoDB.updateItem(params, function(err, data) {
	            if (err) console.log(err, err.stack); // an error occurred
	            else   
	            	console.log("updateOneTrailer success"); 
    		});
    		break;
		}
	}
}


function invokeIdLessMovieDeletion(callback) {
	let params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:deleteIdLessMovies-dev",
		InvocationType: "Event"
	};
	lambda.invoke(params, (err, data) => {
		if (err) 
			console.error(err, null);
		else {
			console.log(data);
			callback();
		}     
	});
}


function deleteNoId() {
	// scan options for DynamoDB table
    let params = {
        TableName: 'movie_table',
        ReturnConsumedCapacity: 'TOTAL',
        FilterExpression: 'attribute_not_exists (tmdb_id)'
    };

    dynamoDB.scan(params, function(error, data) {
        if (error)
            console.error(error.stack);
        else {
            data.Items.forEach(function(item) {
            	console.log("Idless movie: " + item.title.S);
            	if (!item.tmdb_id) {
            		var params_d = {
						Key: {
							"title": {
						    	S: item.title.S
						    } 
						}, 
						TableName: "movie_table"
					};
					dynamoDB.deleteItem(params_d, function(err, data) {
						if (err) console.log(err, err.stack); // an error occurred
					    else     console.log(data);           // successful response
					});
            	}
            });
        }
    });
}




