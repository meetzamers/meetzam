'use strict';


module.exports.handler = addUpcomingMovies;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const movieTable = "movie_table";
const histroyTable = "movie_history";
const upcomingTable = "movie_upcoming";

// Add all movies from movie_tables and movie_history into a map.

let map = new Map();

// query upcomming movies, if a movie if already existed in the map, then ignore it.
// otherwise, add this movie in to movie_upcoming

function addUpcomingMovies (event, context, callback) {

	const scanMovieTable = new Promise((resolve, reject) => {
		console.log("===== scanMovieTable ====> BEGIN");
	    const params = {
	        TableName: movieTable,
	        ReturnConsumedCapacity: 'TOTAL'
	    };
	    dynamoDB.scan(params, function(error, data) {
	    	if (error) {
	    		console.error(error.stack);
	    		reject(error);
	    	} else {
	    		console.log("===== scanMovieTable ====> SUCCESS");
	    		data.Items.forEach((item) => {
	    			console.log("set: ", item.title.S);
	    			map.set(item.title.S, item.tmdb_id.S);
	    		});
	    		resolve("===== scanMovieTable ====> COMPLETE");
	        }
	    });	
	});

	const scanHistoryTable = (result) => {
		return new Promise((resolve, reject) => {
			if (result) {
				console.log(result);
				console.log("===== scanHistoryTable ====> BEGIN");
			    const params = {
			        TableName: histroyTable,
			        ReturnConsumedCapacity: 'TOTAL'
			    };
			    dynamoDB.scan(params, function(error, data) {
			    	if (error) {
			    		console.error(error.stack);
			    		reject(error);
			    	} else {
			    		console.log("===== scanHistoryTable ====> SUCCESS");
			    		data.Items.forEach((item) => {
			    			console.log("set: ", item.title.S);
			    			map.set(item.title.S, item.tmdb_id.S);
			    		});
			    		resolve("===== scanHistoryTable ====> COMPLETE");
			        }
			    });	
			} else reject("result is undefined");
		});
	}; 


	const scanUpcomingTable = (result) => {
		return new Promise((resolve, reject) => {
			if (result) {
				console.log(result);
				console.log("===== scanUpcomingTable ====> BEGIN");
			    const params = {
			        TableName: upcomingTable,
			        ReturnConsumedCapacity: 'TOTAL'
			    };
			    dynamoDB.scan(params, function(error, data) {
			    	if (error) {
			    		console.error(error.stack);
			    		reject(error);
			    	} else {
			    		console.log("===== scanUpcomingTable ====> SUCCESS");
			    		resolve(data.Items);
			        }
			    });	
			} else reject("result is undefined");
		});
	}; 

	const deleteUpcoming = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== deleteUpcoming ====> BEGIN");
                let promises = [];
                items.forEach((item) => {
                    promises.push(deleteOne(item));
                });
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== deleteUpcoming ====> COMPLETE");
                        resolve("===== deleteUpcoming ====> RESOLVED");
                    })
                    .catch(error => reject(error));
            } else reject("items is undefined");
        });
    };

    const deleteOne = (item) => {
        return new Promise((resolve, reject) => {
            if (item) {
                var params_d = {
                        Key: {
                            "title": {
                                S: item.title.S
                            } 
                        }, 
                        TableName: upcomingTable
                };
                dynamoDB.deleteItem(params_d, function(error, data) {
                    if (error) {
                        console.error(error.stack);
                        reject(error);
                    } else {
                        console.log(data);
                        resolve(true);
                    }
                });
            } else reject("item is undefined");
        });
    };

	const getUpcoming = (result) => {
		return new Promise((resolve, reject) => {
			if (result) {
				console.log(result);
				console.log("===== getUpcoming =====");
		        let params = {
		            FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getUpcomingMovies-dev",
		            InvocationType: "RequestResponse"
		        };
		        lambda.invoke(params, (err, data) => {
		            if (err) {
		                console.error(err, err.stack);
		                reject(err);
		            }
		            else  {
		                console.log("==== getUpcoming =====> SUCCESS");
		                resolve(JSON.parse(data.Payload));
		            }           
		        });
			} else reject("result if undefined");
		});
	};

	const processUpcoming = (Payload) => {
		return new Promise((resolve, reject) => {
			if (Payload) {
				console.log("===== processUpcoming ====> BEGIN");
				let promises = [];
				let length = Payload.results.length;
				for (let i = 0; i < length; i++) {
					const item = Payload.results[i];
					const title = item.title;
					if (!map.has(title)) {
						console.log("title: " + title);
						promises.push(updateOne(item));
					}
				}
				Promise.all(promises)
					.then(fulfilled => {
						console.log("===== processUpcoming ====> COMPLETE");
						resolve("===== processUpcoming ====> RESOLVED");
					})
					.catch(error => reject(error));
			} else reject("Payload is undefined");
		});
	};

	const updateOne = (item) => {
        return new Promise((resolve, reject) => {
            if (item) {
                console.log("===== updateOne ====> BEGIN");

                const title = item.title;
                const tmdb_id = item.id.toString();
                const overview = item.overview;
                const poster_path = item.poster_path;
                const release_date = item.release_date;

                const params = {
                    Key: {
                        "title": {
                            S: title
                        }
                    },
                    ExpressionAttributeNames: {
                        "#tmdb_id": "tmdb_id",
                        "#poster_path": "poster_path",
                        "#overview": "overview",
                        "#release_date": "release_date"
                    },
                    ExpressionAttributeValues: {
                        ":tmdb_id": {
                            S: tmdb_id
                        },
                        ":poster_path": {
                            S: poster_path
                        },
                        ":overview": {
                        	S: overview
                        },
                        ":release_date": {
                        	S: release_date
                        }
                    },
                    ReturnValues: "ALL_NEW",
                    TableName: upcomingTable,
                    UpdateExpression: "SET #tmdb_id = :tmdb_id, #poster_path = :poster_path, #overview = :overview, #release_date = :release_date" 
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
                
            } else reject("item is undefined");
        });
    };

    const run = () => {
        scanMovieTable
            .then(scanHistoryTable)
            .then(scanUpcomingTable)
            .then(deleteUpcoming)
            .then(getUpcoming)
            .then(processUpcoming)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();

}