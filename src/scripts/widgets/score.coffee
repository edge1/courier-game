utils = require '../shared/utils.coffee'
Widget = require './widget.coffee'

class Score extends Widget

    constructor: ( classNames = 'widget', visible = true, id = "", attributes = {}, element = null, type = 'div' ) ->
        super classNames
        
        star = new Widget 'alabom-game-engine-common-score-star'
        star.appendTo @

        @tf = new Widget ['alabom-game-engine-common-score-text']
        @tf.appendTo @
        @set 0

    set: (s) =>
        s = s.toString()
        while s.length < 4
            s = '0' + s

        @tf._source.innerText = s

    color: (c) =>
        @tf._source.style.color = c


module.exports = Score
