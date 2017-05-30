"use strict";

// module RDKafka.Consumer

var kafka = require('node-rdkafka');

function consumeImpl(onReady) {
    return function (options) {
        return function (topics) {
            return function (onError) {
                return function (onData) {
                    return function (error) {
                        return function (success) {
                            return function () {
                                var consumer = new kafka.KafkaConsumer(options);

                                consumer.on('error', function (e) {
                                    return error(e)();
                                });
                                consumer.on('ready', function() {
                                    consumer.subscribe(topics);
                                    onReady(consumer);
                                    return success(consumer)();
                                });
                                consumer.on('data', function (d) {
                                    return onData(d)();
                                });
                                consumer.on('event.error', function (e) {
                                    return onError(e)();
                                });
                                consumer.connect();
                            };
                        };
                    };
                };
            };
        };
    };
}

function consumeStreaming(streamingOptions) {
    return function (options) {
        return function (topics) {
            return function (onError) {
                return function (onData) {
                    return function (error) {
                        return function (success) {
                            return function () {
                                try {
                                    var consumer = new kafka.KafkaConsumer(options);
                                    var stream = consumer.getReadStream(topics, streamingOptions);
                                    stream.on('error', function (e) {
                                        return error(e)();
                                    });
                                    stream.consumer.on('event.error', function (e) {
                                        return onError(e)();
                                    });
                                    stream.on('data', function (e) {
                                        return onData(e)();
                                    });
                                    success(stream.consumer)();
                                } catch(err) {
                                    return error(err)();
                                }
                            };
                        };
                    };
                };
            };
        };
    }
}

exports.consumeStreaming = consumeStreaming;

exports.consumeFlowing = consumeImpl(function (consumer) {
    consumer.consume();
});

exports.consumeNonFlowing = function consumeNonFlowing(interval) {
    return function (count) {
        return consumeImpl(function (consumer) {
            setInterval(function () {
                consumer.consume(count);
            }, interval);
        });
    };
};
