'use strict';


module.exports.handler = deleteHistoryMoviesFromMovieTable;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function deleteHistoryMoviesFromMovieTable (event, context, callback) {
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