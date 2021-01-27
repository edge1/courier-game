/**
 * Wrap .coffee for webpack loaders.
 * This module is the main entrypoint
 */


/**
 * 
 */
require('./../styles/alabom-game.sass');

/**
 * Simple shim for ES6 Set class:) Do not bring entire babel-polyfill:))))))
 */
window.Set = function (list) {
    this._list = list;
}
window.Set.prototype.has = function (item) {
    return !!(this._list.indexOf(item) > -1)
}

/**
 * Promise polyfill (auto!)
 */

//require('es6-promise').polyfill();

const alabomGame = require("./alabom-game.coffee");

module.exports = alabomGame;