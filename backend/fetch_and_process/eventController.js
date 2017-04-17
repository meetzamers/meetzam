'use strict';

module.exports.handler = eventController;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function eventController (event, context, callback) {

	const getUpcomingMovies = new Promise ((resolve, reject) => {
		const parameters = {
				FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getUpcomingMovies-dev",
				InvocationType: "RequestResponse",
		};
		lambda.invoke(parameters, (err, data) => {
			if (err) {
				console.error(err, null);
				const reason = new Error(err);
				reject(reason);
			} 
			else {
				console.log(data.Payload);
				resolve(data.Payload);
			}
		});		

		}
	);



}