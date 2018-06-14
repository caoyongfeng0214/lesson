const merge = require("webpack-merge");
const common = require("./webpack.common.js");
const webpack = require("webpack");

module.exports = merge(common, {
  devtool: "inline-source-map",
  devServer: {
    hot: true,
    contentBase: "./public",
    port: 3033,
    proxy: [
      {
        context: ["/_mg", "/api"],
        target: "http://localhost:3000"
      }
    ]
  },
  plugins: [new webpack.HotModuleReplacementPlugin()],
  mode: "development"
});
