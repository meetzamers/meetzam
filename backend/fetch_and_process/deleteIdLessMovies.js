'use strict';

// scan movie_table and delete movies that doesn't have tmdb_id
module.exports.handler = scanMovieTableAndDeleteIdLessMovies;


const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function scanMovieTableAndDeleteIdLessMovies(event, context, callback) {

	const scanTable = new Promise((resolve, reject) => {
		console.log("===== scanTable ====> BEGIN");
	    const params = {
	        TableName: tableName,
	        ReturnConsumedCapacity: 'TOTAL',
	        FilterExpression: 'attribute_not_exists (tmdb_id)'
	    };
	    dynamoDB.scan(params, function(error, data) {
	    	if (error) {
	    		console.error(error.stack);
	    		reject(error);
	    	} else {
	    		console.log("===== scanTable ====> SUCCESS");
	    		resolve(data.Items);
	        }
	    });	
	});

	const deleteIDless = (items) => {
		return new Promise((resolve, reject) => {
			if (items) {
				console.log("===== deleteIDless ====> BEGIN");
				let promises = [];
				items.forEach((item) => {
					promises.push(deleteOne(item));
				});
				Promise.all(promises)
					.then(fulfilled => {
						console.log("===== deleteIDless ====> COMPLETE");
						resolve("===== deleteIDless ====> RESOLVED");
					})
					.catch(error => reject(error));
			} else reject("result of scanTable is undefined");
		});
	};

	const deleteOne = (item) => {
		return new Promise((resolve, reject) => {
			if (item) {
				console.log("===== deleteOne ====> BEGIN");
				if (!item.tmdb_id) {
	        		var params_d = {
						Key: {
							"title": {
						    	S: item.title.S
						    } 
						}, 
						TableName: tableName
					};
					dynamoDB.deleteItem(params_d, function(err, data) {
						if (err) {
			            	console.log(err, err.stack); // an error occurred
			            	reject(err);
			            } else {
			            	console.log("===== deleteOne ====> COMPLETE");
			            	resolve(true); 
			            } 
					});
				} 	
			} else reject("item is undefined");
		});
	};

	const run = () => {
		scanTable
			.then(deleteIDless)
			.then(fulfilled => callback(null, fulfilled))
			.catch(error => callback(error.message));
	};

	run();
}






