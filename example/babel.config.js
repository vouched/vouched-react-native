module.exports = {
  presets: ["module:metro-react-native-babel-preset"],
  plugins: [
    ["module:react-native-dotenv"],
    [
      "module-resolver",
      {
        root: ["./src"],
        extensions: [
          ".ios.js",
          ".android.js",
          ".js",
          ".ts",
          ".tsx",
          ".json",
          ".jsx",
        ],
        alias: {
          tests: ["./tests/"],
          config: "./src/config",
          components: "./src/components",
          common: "./src/common",
        },
      },
    ],
  ],
};
