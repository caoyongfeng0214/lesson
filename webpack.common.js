const path = require("path");
const CleanWebpackPlugin = require("clean-webpack-plugin");

module.exports = {
  entry: {
    index: "./mg_dev/index.js"
  },
  plugins: [new CleanWebpackPlugin(["public/mgjs"])],
  output: {
    filename: "mgjs/[name].bundle.js",
    publicPath: "/",
    path: path.resolve(__dirname, "public")
  },
  module: {
    rules: [
      {
        test: /\.js|jsx$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader"
      }
    ]
  }
};
