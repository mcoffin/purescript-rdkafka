"use strict";

// module RDKafka.Producer

var kafka = require('node-rdkafka');

function producerF(options) {
    return function (interval) {
        return function (onEventError) {
            return function (success, error) {
                var producer = new kafka.Producer(options);
                producer.on('ready', function () {
                    return success(producer);
                });
                producer.on('error', error);
                producer.on('event.error', function (e) {
                    return onEventError(e)();
                });
                producer.connect();
                producer.setPollInterval(interval);
            };
        };
    };
}

function produceF(producer) {
    return function (topic) {
        return function (partition) {
            return function (value) {
                return function (key) {
                    return function () {
                        producer.produce(
                            topic,
                            partition,
                            value,
                            key,
                            Date.now()
                        );
                    };
                };
            };
        };
    };
}

exports.producerF = producerF;
exports.fNull = null;
exports.produceF = produceF;
