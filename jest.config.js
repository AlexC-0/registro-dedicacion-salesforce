const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
module.exports = {
    ...jestConfig,
    testMatch: ['**/__tests__/**/*.test.js'],
    collectCoverageFrom: ['force-app/main/default/lwc/p07DedicacionSemanal/*.js'],
    coverageReporters: ['text', 'json-summary', 'lcov'],
    testPathIgnorePatterns: [...jestConfig.testPathIgnorePatterns, '/tmp/', '/.private/']
};
