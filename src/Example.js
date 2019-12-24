'use strict';

// module Example

exports.consoleLog = function consoleLog(v) {
    return () => console.log(v);
};
