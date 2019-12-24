'use strict';

// module RDKafka.Client

const { promisify } = require('util');

function logSideEffect(v) {
    console.log(v);
    return v;
}

exports.queryWatermarkOffsetsImpl = function queryWatermarkOffsetsImpl(topic, partition, timeout, client) {
    return () => promisify(client.queryWatermarkOffsets).bind(client)(topic, partition, timeout);
};

exports.getMetadataImpl = function getMetadataImpl(topic, timeout, client) {
    const options = {
        topic: topic,
        timeout: timeout
    };
    return () => promisify(client.getMetadata).bind(client)(options)
        .then(logSideEffect);
};
