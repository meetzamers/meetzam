'use strict';
const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

var movieTitles = new Map();

module.exports.parseData = (event, context, callback) => {
	parse_start(() => {
		parse_tmdb(() => {
			callback(null ,"success!");
		});
	});
};


function parse_start(callback) {
	let tms_params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getDataTMS-dev",
		InvocationType: "RequestResponse"
	};

	//invoke function to get tms data
	lambda.invoke(tms_params, (err, data) => {
		if (err) 
			console.error(err, null);
		else  {
			updateMovieTableForTMS(JSON.parse(data.Payload), () => {
				callback();
			});
		}   		
	});
}

function updateMovieTableForTMS(Payload, callback) {
	var length = Payload.length;
	for (var i = 0; i < length; i++) {
		var title = Payload[i].title;
		//console.log("title is "+ title);

		var shortDescription = Payload[i].shortDescription;
		//console.log("shortDescription is "+ shortDescription);

		var longDescription = Payload[i].longDescription;
		//console.log("longDescription is "+ longDescription);

		//var releaseDate = Payload[i].releaseDate;
		//console.log("releaseDate is "+ releaseDate);

		//var tmsId = Payload[i].tmsId;
		//console.log("tmsId is "+ tmsId);

		//var rootId = Payload[i].rootId;
		//console.log("rootId is "+ rootId);

		var releaseYear = Payload[i].releaseYear.toString();
		var genres = Payload[i].genres;
		var topCast = Payload[i].topCast;
		var directors = Payload[i].directors;

		movieTitles.set(title, releaseYear);
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
            else     console.log(data);           // successful response
        });
	}
	callback();
}



function parse_tmdb(callback) {
	movieTitles.forEach(prepareGet);
	callback();
}

function prepareGet(value, key, map) {
	var title = key.replace(/\ /g, "%20");
	var year = value.toString();
	getOneMovieTMDB(title, year, () => {});	
} 

function getOneMovieTMDB(title, year, callback) {
	console.log("fetch movie info for: " + title);
	let payload = {
		"title": title,
		"year": year
	};
	let tmdb_params = {
		FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getDataTMDB-dev",
		InvocationType: "RequestResponse",
		Payload: JSON.stringify(payload)
	};
	//invoke function to get tmdb data
	lambda.invoke(tmdb_params, (err, data) => {
		if (err) 
			console.error(err, null);
		else {
			console.log("payload = " + data.Payload);
			updateMovieTalbeTMDB(title.replace(/\%20/g, " "), JSON.parse(data.Payload), () => {});
		}     
	});
	callback();
}


function updateMovieTalbeTMDB(title, Payload, callback) {
	var total = Payload.total_results;
	var results = Payload.results;
	var length = results.length;
	if (total > 0) {
		for (var i = 0; i < 1; i++) {
			var tmdb_id = results[i].id;
			var poster_path = results[i].poster_path;
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
	                	S: tmdb_id.toString()
	                },
	                ":poster_path": {
	                	S: poster_path
	                }
	        	},
	        	ReturnValues: "ALL_NEW",
	        	TableName: "movie_table",
	      	 	UpdateExpression: "SET #tmdb_id = :tmdb_id, #poster_path = :poster_path" 
			};
			console.log("updateMovieTalbeTMDB!");
			dynamoDB.updateItem(params, function(err, data) {
	            if (err) console.log(err, err.stack); // an error occurred
	            else     console.log(data);           // successful response
	    	});
		}
	}
	callback();
}
