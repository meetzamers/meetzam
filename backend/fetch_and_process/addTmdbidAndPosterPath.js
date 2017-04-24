'use strict';

// scan entire movie_table. For each item, query 'title' and 'releaseYear' and invoke getOneMovie function to get tmdb_id and poster_path, then update the item to include 'tmdb_id' and 'poster_path'. 
module.exports.handler = scan_invoke_and_update;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function scan_invoke_and_update (event, context, callback) {

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


    const updateTable = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== updateTable ====> BEGIN");
                let promises = [];
                items.forEach((item) => {
                    promises.push(fetchOne(item));
                });
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== updateTable ====> COMPLETE");
                        resolve("===== updateTable ====> RESOLVED");
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
                title = title.replace(/\ /g, "%20"); 
                var year = item.releaseYear.S;
                let payload = {
                    "title": title,
                    "year": year
                };
                let tmdb_params = {
                    FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getOneMovie-dev",
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
                        updateOne(title.replace(/\%20/g, " "), JSON.parse(data.Payload))
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
                var total = Payload.total_results;
                var results = Payload.results;
                if (total > 0) {
                    var tmdb_id = results[0].id.toString();
                    var poster_path = results[0].poster_path;
                    var popularity = results[0].popularity.toString();
                    var params = {
                        Key: {
                            "title": {
                                S: title
                            }
                        },
                        ExpressionAttributeNames: {
                            "#tmdb_id": "tmdb_id",
                            "#poster_path": "poster_path",
                            "#popularity": "popularity"
                        },
                        ExpressionAttributeValues: {
                            ":tmdb_id": {
                                S: tmdb_id
                            },
                            ":poster_path": {
                                S: poster_path
                            },
                            ":popularity": {
                                S: popularity
                            }
                        },
                        ReturnValues: "ALL_NEW",
                        TableName: tableName,
                        UpdateExpression: "SET #tmdb_id = :tmdb_id, #poster_path = :poster_path, #popularity = :popularity" 
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
                }
            } else reject("title or Payload is undefined");
        });
    };


    const run = () => {
        scanTable
            .then(updateTable)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();

}
