const webpack = require('webpack');
const CleanWebpackPlugin = require("clean-webpack-plugin");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
//const JavaScriptObfuscator = require('webpack-obfuscator');
// const CssUrlRelativePlugin = require('css-url-relative-plugin');

const path = require("path");

// Small trick how to intercept environment in webpack 4:
module.exports = (env, argv) => {
  console.log('Mode: ', argv.mode)        // outputs development
  var conf = {
    entry: {
      "alabom-game": "./src/scripts/init.js",

    },
    output: {
      path: path.resolve(__dirname, "dist"),
      // path: "dist",
      filename: "alabom-game.js",
      publicPath: "/dist/",
      library: 'alabomGame',
      libraryTarget: 'umd',
      // libraryExport: 'default',
      globalObject: 'window'
    },
    resolve: {
      extensions: ['.js', '.coffee']
    },
    module: {
      rules: [
        { test: /\.coffee$/,
            // exclude: /(node_modules|bower_components)/,
            loader: 'coffee-loader'
        },
        // // CSS - today we`re using postcss script as much convenient (I don know any simple solutions to map each entry to separate css file)

        // {
        //   test: /\.s[c|a]ss$/,
        //   use: [
        //     'style-loader',
        //     MiniCssExtractPlugin.loader,
        //     'css-loader',
        //     // 'postcss-loader',
        //     'sass-loader'
        //   ]
        // }

      ]
    },
    plugins: [
    ],
    optimization: {
    }
  };

  if (argv.mode === 'production') {
    // PROD mode:
    // conf.plugins.unshift(
    //   new CleanWebpackPlugin(['dist/*.*'])
    // );


    conf.output.filename = "alabom-game.min.js";

    conf.plugins.push(
      new MiniCssExtractPlugin({
        filename: 'css/alabom-game-style-dyn-min.css',
      })
    );

    /*conf.plugins.push(
    	new JavaScriptObfuscator ({
          rotateUnicodeArray: true
      })
    );*/

    // conf.plugins.push(
    //   new CssUrlRelativePlugin({
    //     root: 'dev/'
    //   })
    // );

    // conf.entry = {
    //   "alabom-game.min": "./src/scripts/init.js"
    // }

    conf.optimization = {
      minimize: true
    }


    conf.module.rules.push(
      {
        // test: /\.css$/,
        // include: /styles|node_modules/,
        // use: ["style-loader", "css-loader", "sass-loader"]

        test: /\.s[c|a]ss$/,
        include: /styles|node_modules/,
        use: [
          'style-loader',
          MiniCssExtractPlugin.loader,
          'css-loader',
          // 'postcss-loader',
          'sass-loader'
        ]

      }
    );


    // conf.plugins.push(new UglifyJsPlugin({
    //     test: /\.js($|\?)/i,
    //     uglifyOptions: {
    //         output: {
    //             comments: false
    //         },
    //         compress: {
    //           ecma: 5,
    //           booleans: true,
    //           warnings: false,
    //           drop_console: false
    //         }
    //     }
    //   })
    // );

  } else {
    // DEV mode

    conf.devtool = "source-map";
    conf.devServer = {
      open: false,
      // port: 9090,
      // openPage: "./example_linux/index.html",
      // proxy: { // proxy URLs to backend development server
      //   '/api/1.0': 'http://localhost:5050'
      // },
      contentBase: path.join(__dirname, 'test_page'), // boolean | string | array, static file location
      publicPath: '/dist/',
      // compress: true, // enable gzip compression
      // historyApiFallback: true, // true for index.html upon 404, object for multiple paths
      hot: true, // hot module replacement. Depends on HotModuleReplacementPlugin
      inline: true,
      https: false, // true for self-signed, object for cert authority
      noInfo: true // only errors & warns on hot reload
    };

    conf.plugins.push(new webpack.HotModuleReplacementPlugin());
    conf.plugins.push(
      new MiniCssExtractPlugin({
        filename: 'css/alabom-game-style-dyn.css',
      })
    )

    conf.module.rules.push(
      {
        // test: /\.css$/,
        // include: /styles|node_modules/,
        // use: ["style-loader", "css-loader", "sass-loader"]

        test: /\.s[c|a]ss$/,
        include: /styles|node_modules/,
        use: [
          'style-loader',
          MiniCssExtractPlugin.loader,
          'css-loader',
          // 'postcss-loader',
          'sass-loader'
        ]

      }
    );
  }

  return conf;
}
