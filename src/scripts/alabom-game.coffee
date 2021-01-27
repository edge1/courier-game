Widget = require './widgets/widget.coffee'
Engine = require './widgets/engine.coffee'
Mute = require './widgets/mute.coffee'
StartScreen = require './widgets/startScreen.coffee'
SelectScreen = require './widgets/selectScreen.coffee'
utils = require './shared/utils.coffee'

class alabomGame extends Widget

    constructor: ( element ) ->
        super ['alabom-game-style', 'alabom-game-engine-common-noselect']
        document.getElementById( element ).appendChild @_source

        @mute = new Mute()
        @startScreen = new StartScreen @, @mute
        @selectScreen = new SelectScreen @, @mute, @startScreen
        @engine = new Engine @, @mute
        @mute.appendTo @

        @start()

    start: =>
        @startScreen.start =>
            @selectScreen.start (loc) =>
                @engine.start loc, =>
                    @start()

        # @startScreen.start =>
        #      @engine.start 'city'

        # utils.timeout 1000, =>
        #     @engine.start 'city'

        # utils.timeout 2000, =>
        #     @engine.stop()
        #
        # utils.timeout 3000, =>
        #     @engine.start 'city'
        #
        # utils.timeout 4000, =>
        #     @engine.stop()
        #
        # utils.timeout 5000, =>
        #     @engine.start 'city'

module.exports = alabomGame
