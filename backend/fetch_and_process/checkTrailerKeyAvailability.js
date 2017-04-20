'use strict';

// scan movie_table and check availability of trailer_key. For those movies that doesn't have a trailer_key, mark trailer_key as "unavailable".
module.exports.handler = scanMovieTableAndCheckTrailerKeyAvailability;


const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function scanMovieTableAndCheckTrailerKeyAvailability(event, context, callback) {

	const scanTable = new Promise((resolve, reject) => {
		console.log("===== scanTable ====> BEGIN");
	    const params = {
	        TableName: tableName,
	        ReturnConsumedCapacity: 'TOTAL',
	        FilterExpression: 'attribute_not_exists (trailer_key)'
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

	const updateTrailerKeyLess = (items) => {
		return new Promise((resolve, reject) => {
			if (items) {
				console.log("===== updateTrailerKeyLess ====> BEGIN");
				let promises = [];
				items.forEach((item) => {
					if (!item.trailer_key) 
						promises.push(updateOne(item));
				});
				Promise.all(promises)
					.then(fulfilled => {
						console.log("===== updateTrailerKeyLess ====> COMPLETE");
						resolve("===== updateTrailerKeyLess ====> RESOLVED");
					})
					.catch(error => reject(error));
			} else reject("result of scanTable is undefined");
		});
	};


	const updateOne = (item) => {
		return new Promise((resolve, reject) => {
			if (item) {
				console.log("===== updateOne ====> BEGIN");
				var params = {
					Key: {
		            	"title": {
		                	S: item.title.S
		            	}
		        	},
		        	ExpressionAttributeNames: {
		                "#trailer_key": "trailer_key"
		        	},
		        	ExpressionAttributeValues: {
		                ":trailer_key": {
		                	S: "unavailable"
		                }
		        	},
		        	ReturnValues: "ALL_NEW",
		        	TableName: tableName,
		      	 	UpdateExpression: "SET #trailer_key = :trailer_key" 
				};
				dynamoDB.updateItem(params, function(err, data) {
					if (err) {
		            	console.log(err, err.stack); // an error occurred
		            	reject(err);
		            } else {
		            	console.log("===== updateOne ====> COMPLETE");
		            	resolve(true); 
		            } 
				});
			} else reject("item is undefined");
		});
	};

	const run = () => {
		scanTable
			.then(updateTrailerKeyLess)
			.then(fulfilled => callback(null, fulfilled))
			.catch(error => callback(error.message));
	};

	run();
}






