module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  // These are the defaults for Jest in case we want to change them later:
  roots: ["<rootDir>"],
  testRegex: "(/__tests__/.*|(\\.|/)(test|spec))\\.tsx?$",
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
};
