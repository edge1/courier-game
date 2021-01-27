utils = require '../shared/utils.coffee'
Widget = require './widget.coffee'

class Anchor extends Widget

    constructor: ( elem, mid = true, left = 0, bottom = 0 ) ->
        super 'edge-game-common-anchor'

        @appendTo elem

        if mid
            @_source.style.left = ((utils.getStyleValueNumber elem._source, 'width') / 2 - 50 ) + 'px'
            @_source.style.bottom = ((utils.getStyleValueNumber elem._source, 'height') / 2 - 50 ) + 'px'
        else
            if left? and bottom?
                @_source.style.left = left - 50 + 'px'
                @_source.style.bottom = bottom - 50 + 'px'


module.exports = Anchor
