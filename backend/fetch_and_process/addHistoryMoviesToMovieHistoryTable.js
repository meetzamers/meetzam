'use strict';


module.exports.handler = addHistoryMoviesToMovieHistoryTable;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});


function addHistoryMoviesToMovieHistoryTable (event, context, callback) {

	// scan options for DynamoDB table
    let params = {
        TableName: 'movie_table',
        ReturnConsumedCapacity: 'TOTAL'
    };
    dynamoDB.scan(params, function(error, data) {
    	if (error)
            console.error(error.stack);
        else {
        	data.Items.forEach((item) => {
        		var history = item.isHistory.BOOL;
        		if (history === true) {

					var title = item.title.S;
					console.log(title);
					var shortDescription = item.shortDescription.S;
					console.log(shortDescription);
					var longDescription = item.longDescription.S;
					console.log(longDescription);
					var genres = item.genres.SS;
					console.log(genres);
					var topCast = item.topCast.SS;
					console.log(topCast);
					var directors = item.directors.SS;
					console.log(directors);
					var releaseYear = item.releaseYear.S;
					console.log(releaseYear);
					var tmdb_id = item.tmdb_id.S;
					console.log(tmdb_id);
					var poster_path = item.poster_path.S;
					console.log(poster_path);
					var trailer_key = item.trailer_key.S;
					console.log(trailer_key);

					var db_params = { 
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
			                "#releaseYear": "releaseYear",
			                "#tmdb_id": "tmdb_id",
			                "#poster_path": "poster_path",
	    	                "#trailer_key": "trailer_key"            
			        	},
			        	ExpressionAttributeValues: {
			                ":tmdb_id": {
			                	S: tmdb_id
			                },
			                ":poster_path": {
			                	S: poster_path
			                },
	    	                ":trailer_key": {
		                		S: trailer_key
		                	},
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
			        	TableName: "movie_history",
			      	 	UpdateExpression: "SET #releaseYear = :releaseYear, #shortDescription = :shortDescription, #longDescription = :longDescription, #genres = :genres, #topCast = :topCast, #directors = :directors, #trailer_key = :trailer_key, #tmdb_id = :tmdb_id, #poster_path = :poster_path" 
					};
					dynamoDB.updateItem(db_params, function(err, data) {
			            if (err) console.log(err, err.stack); // an error occurred
			            else   
			            	console.log("add history movie success"); 
		    		});
        		}
        	});
        }
    });	
}