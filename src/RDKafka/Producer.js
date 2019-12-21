'use strict';

// module RDKafka.Produer

const Kafka = require('node-rdkafka');
const { promisify } = require('util');

exports.producerImpl = function producerImpl(onError, options) {
    return () => new Promise((resolve, reject) => {
        const producer = Kafka.Producer(options);
        producer.connect();
        producer.on('ready', () => resolve(producer));
        producer.on('error', e => reject(e));
        producer.on('event.error', e => onError(e)());
    });
};

exports.produceImpl = function produceImpl(topic, partition, key, value, producer) {
    return () => producer.produce(topic, partition, value, key);
};

exports.flushImpl = function flushImpl(timeout, producer) {
    return () => promisify(producer.flush).bind(producer)(timeout);
};

exports.disconnectImpl = function disconnectImpl(timeout, producer) {
    return () => promisify(producer.disconnect).bind(producer)(timeout);
};

exports.foreignNull = null;
