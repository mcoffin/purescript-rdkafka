'use strict';

// module RDKafka.Client

const { promisify } = require('util');

exports.queryWatermarkOffsetsImpl = function queryWatermarkOffsetsImpl(topic, partition, timeout, client) {
    return () => promisify(client.queryWatermarkOffsets).bind(client)(topic, partition, timeout);
};
