'use strict';


module.exports.handler = deleteHistoryMoviesFromMovieTable;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function deleteHistoryMoviesFromMovieTable (event, context, callback) {



    const scanTable = new Promise((resolve, reject) => {
        console.log("===== scanTable =====");
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

    const deleteHistory = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== deleteHistory ====> BEGIN");
                let promises = [];
                items.forEach((item) => {
                    var history = item.isHistory.BOOL;
                    if (history === true) 
                        promises.push(deleteOne(item));
                });
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== deleteHistory ====> COMPLETE");
                        resolve("===== deleteHistory ====> RESOLVED");
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
                        TableName: tableName
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

    const run = () => {
        scanTable
            .then(deleteHistory)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();

}