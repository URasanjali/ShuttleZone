module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020, // Use the latest ECMAScript version
  },
  extends: [
    "eslint:recommended", // Use recommended ESLint rules
  ],
  rules: {
    "indent": ["error", 2], // Enforce 2-space indentation
    // eslint-disable-next-line max-len
    "quotes": ["error", "double", { allowTemplateLiterals: true }], // Allow double quotes and template literals
    "semi": ["error", "always"], // Require semicolons
    "no-console": "off", // Allow console.log statements
    "prefer-arrow-callback": "off", // Disable prefer-arrow-callback rule
    "no-restricted-globals": "off", // Disable no-restricted-globals rule
  },
  overrides: [
    {
      files: ["**/*.spec.*"], // Apply rules to test files
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
