'use strict';

module.exports.handler = scan_invoke_and_update_comments;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function scan_invoke_and_update_comments(event, context, callback) {

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

    const updateComments = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== updateComments ====> BEGIN");
                let promises = [];
                items.forEach((item) => {
                    promises.push(fetchOne(item));
                });
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== updateComments ====> COMPLETE");
                        resolve("===== updateComments ====> RESOLVED");
                    })
                    .catch(error => reject(error));
            } else reject("items is undefined");
        });
    };


    const fetchOne = (item) => {
        return new Promise((resolve, reject) => {
            if (item) {
                console.log("===== fetchOne ====> BEGIN");
                const title = item.title.S;
        		const id = item.tmdb_id.S;
				const payload = {
					"id": id
				};
				const tmdb_params = {
					FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getMovieComments-dev",
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
                const results = Payload.results;
				const len = results.length;
				let comment_author = "unavailable";
				let comment_body = "unavailable";
				if (len > 0) {
					comment_author = results[0].author;
					comment_body = results[0].content;
				}
				const params = {
					Key: {
		            	"title": {
		                	S: title
		            	}
		        	},
		        	ExpressionAttributeNames: {
		                "#comment_author": "comment_author",
		                "#comment_body": "comment_body"
		        	},
		        	ExpressionAttributeValues: {
		                ":comment_author": {
		                	S: comment_author
		                },
		                ":comment_body": {
		                	S: comment_body
		                }
		        	},
		        	ReturnValues: "ALL_NEW",
		        	TableName: tableName,
		      	 	UpdateExpression: "SET #comment_author = :comment_author, #comment_body = :comment_body" 
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
            } else reject("title or Payload is undefined");
        });
    };

    const run = () => {
		scanTable
			.then(updateComments)
			.then(fulfilled => callback(null, fulfilled))
			.catch(error => callback(error.message));
	};

	run();
}

