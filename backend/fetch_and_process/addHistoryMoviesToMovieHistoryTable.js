'use strict';


module.exports.handler = addHistoryMoviesToMovieHistoryTable;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";
const histroy_table = "movie_history";


function addHistoryMoviesToMovieHistoryTable (event, context, callback) {


	const scanTable = new Promise((resolve, reject) => {
		console.log("===== scanTable ====> BEGIN");
	    const params = {
	        TableName: tableName,
	        ReturnConsumedCapacity: 'TOTAL'
	    };
	    dynamoDB.scan(params, function(error, data) {
	    	if (error) {
	    		console.error(error.stack);
	    		reject(error);
	    	} else {
	    		console.log("===== scanTable ====> COMPLETE");
	    		resolve(data.Items);
	        }
	    });	
	});

	const updateOne = (item) => {
		return new Promise((resolve, reject) => {
			if (item) {
				var title = item.title.S;
				var shortDescription = item.shortDescription.S;
				var longDescription = item.longDescription.S;
				var genres = item.genres.SS;
				var topCast = item.topCast.SS;
				var directors = item.directors.SS;
				var releaseYear = item.releaseYear.S;
				var tmdb_id = item.tmdb_id.S;
				var poster_path = item.poster_path.S;
				var trailer_key = item.trailer_key.S;
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
		        	TableName: histroy_table,
		      	 	UpdateExpression: "SET #releaseYear = :releaseYear, #shortDescription = :shortDescription, #longDescription = :longDescription, #genres = :genres, #topCast = :topCast, #directors = :directors, #trailer_key = :trailer_key, #tmdb_id = :tmdb_id, #poster_path = :poster_path" 
				};
				dynamoDB.updateItem(db_params, function(err, data) {
			            if (err) {
			            	console.log(err, err.stack); // an error occurred
			            	reject(err);
			            }
			            else {
			            	console.log(data);
			            	resolve(true);
			            }   
		    	});
			} else reject("item is undefined");
		});
	};

	const updateHistory = (items) => {
		return new Promise((resolve, reject) => {
			if (items) {
				console.log("===== updateHistory ====>BEGIN");
                let promises = [];
                items.forEach((item) => {
					let history = item.isHistory.BOOL;
					if (history === true) 
						promises.push(updateOne(item));
				});
				Promise.all(promises)
					.then(fulfilled => {
						console.log("===== updateHistory ====> COMPLETE");
						resolve("===== updateHistory ====> RESOLVED");
					})
					.catch(error => reject(error));
			} else reject("result of scanTable is undefined");
		});
	};

	const run = () => {
		scanTable
			.then(updateHistory)
			.then(fulfilled => callback(null, fulfilled))
			.catch(error => callback(error.message));
	};

	run();



}