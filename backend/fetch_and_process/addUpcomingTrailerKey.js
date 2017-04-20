'use strict';

// scan entire movie_table. For each item, query 'tmdb_id' and invoke getTrailer function to get 'trailer_key', then update the item to include 'trailer_key'.
module.exports.handler = scan_invoke_and_update_trailer_key;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_upcoming";

function scan_invoke_and_update_trailer_key (event, context, callback) {

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
                console.log("===== scanTable ====> SUCCESS");
                resolve(data.Items);
            }
        }); 
    });


    const updateTrailerKeys = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== updateTrailerKeys ====> BEGIN");
                let promises = [];
                items.forEach((item) => {
                    promises.push(fetchOne(item));
                });
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== updateTrailerKeys ====> COMPLETE");
                        resolve("===== updateTrailerKeys ====> RESOLVED");
                    })
                    .catch(error => reject(error));
            } else reject("items is undefined");
        });
    };


    const fetchOne = (item) => {
        return new Promise((resolve, reject) => {
            if (item) {
                console.log("===== fetchOne ====> BEGIN");
               var title = item.title.S;
        		var id = item.tmdb_id.S;
				let payload = {
					"id": id
				};
				let tmdb_params = {
					FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getTrailer-dev",
					InvocationType: "RequestResponse",
					Payload: JSON.stringify(payload)
				};
				lambda.invoke(tmdb_params, (err, data) => {
					if (err) {
                        console.error(err, null);
                        reject(err);
                    }
					else {
						console.log("===== fetchOne ====> COMPLETE");
						updateOne(title, JSON.parse(data.Payload))
							.then(fulfilled => resolve(true))
                            .catch(error => console.log(error.message));
					}     
				});		
            } else reject("item is undefined");
        });
    };

    const updateOne = (title, Payload) => {
        return new Promise((resolve, reject) => {
            if (title && Payload) {
                console.log("===== updateOne ====> BEGIN");
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
				        	TableName: tableName,
				      	 	UpdateExpression: "SET #trailer_key = :trailer_key" 
						};
						dynamoDB.updateItem(params, function(err, data) {
				            if (err) {
	                            console.error(err, null);
	                            reject(err);
	                        }
	                        else {  
	                            console.log("===== updateOne ====> COMPLETE");
	                            resolve(true);
                        	}     
			    		});
			    		break;
					}
				}
            } else reject("title or Payload is undefined");
        });
    };

    const run = () => {
        scanTable
            .then(updateTrailerKeys)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();
}