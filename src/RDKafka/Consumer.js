'use strict';

// module RDKafka.Consumer

const Kafka = require('node-rdkafka');
const { promisify } = require('util');

exports.isBuffer = function isBuffer(v) {
    return (v instanceof Buffer);
};

exports.consumerImpl = function consumerImpl(onError, options, topicOptions, topics) {
    return () => new Promise((resolve, reject) => {
        const consumer = new Kafka.KafkaConsumer(options, topicOptions);
        console.log(consumer);
        consumer.connect();
        console.log(consumer);
        consumer.on('ready', () => {
            consumer.subscribe(topics);
            resolve(consumer);
        });
        consumer.on('error', e => reject(e));
        consumer.on('event.error', e => onError(e)());
        console.log(consumer);
    });
};

exports.consumeBatchImpl = function consumeBatchImpl(batchSize, consumer) {
    return () => promisify(consumer.consume).bind(consumer)(batchSize);
};

exports.consumeStreamImpl = function consumeStreamImpl(cb, consumer) {
    return function () {
        consumer.on('data', data => cb(data)());
        consumer.consume();
    };
};
