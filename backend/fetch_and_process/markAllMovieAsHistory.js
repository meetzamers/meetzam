'use strict';

// // scan entire movie_table. Mark every movie as 'history'.
module.exports.handler = scan_and_mark_history;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table"

function scan_and_mark_history (event, context, callback) {

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

	const mark = (item) => {
		return new Promise((resolve, reject) => {
			if (item) {
				const title = item.title.S;
				const db_params = {
					Key: {
		            	"title": {
		                	S: title
		            	}
		        	},
		        	ExpressionAttributeNames: {
		                "#isHistory": "isHistory"
		        	},
		        	ExpressionAttributeValues: {
		                ":isHistory": {
		                	BOOL: true
		                }
		        	},
		        	ReturnValues: "ALL_NEW",
		        	TableName: tableName,
		      	 	UpdateExpression: "SET #isHistory = :isHistory" 
				};
				dynamoDB.updateItem(db_params, function(err, data) {
		            if (err) {
		            	console.log(err, err.stack); // an error occurred
		            	reject(err);
		            } else {
		            	console.log(data);
		            	resolve(true); 
		            } 
	    		});
			} else reject("item is undefined");
		});
	};

	const markHistory = (items) => {
		return new Promise((resolve, reject) => {
			if (items) {
				console.log("===== markHistory ====> BEGIN");
				let promises = [];
				items.forEach((item) => {
					promises.push(mark(item));
				});
				Promise.all(promises)
					.then(fulfilled => {
						console.log("===== markHistory ====> COMPLETE");
						resolve("===== markHistory ====> RESOLVED");
					})
					.catch(error => reject(error));
			} else reject("result of scanTable is undefined");
		});
	};

	const run = () => {
		scanTable
			.then(markHistory)
			.then(fulfilled => callback(null, fulfilled))
			.catch(error => callback(error.message));
	};

	run();
}



