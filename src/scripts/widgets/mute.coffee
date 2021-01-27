utils = require '../shared/utils.coffee'
Widget = require './widget.coffee'

class Mute extends Widget

    constructor: ( element = null, @state = true ) ->
        super 'alabom-game-engine-mute'
        if element
            @appendTo element
        @setId 'alabom-game-engine-mute'

        @state = utils.restoreValue 'mute', true
        @toggle @state

        @_source.addEventListener 'click', =>
            @toggle()

    toggle: (state = null) =>
        if state?
            @state = state
        else
            @state = !@state

        if @state
            @_source.style.backgroundPosition = '0 0'
            @emit 'unmuted'
        else
            @_source.style.backgroundPosition = '-47px 0'
            @emit 'muted'

        utils.saveValue 'mute', @state

    get: =>
        @state

module.exports = Mute
