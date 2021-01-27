utils = require '../shared/utils.coffee'
Widget = require './widget.coffee'
TweenMax = require 'gsap/umd/TweenMax'

class Help extends Widget

    constructor: ( element = null ) ->
        super 'alabom-game-engine-help'
        if element
            @appendTo element

        @tf = new Widget 'alabom-game-engine-help-text'
        @tf.appendTo @

        if utils.environment() is 'default'
            @tf._source.innerText = 'Чтобы прыгнуть нажмите пробел. Долгое нажатие - большой прыжок'
        else
            @tf._source.innerText = 'Чтобы прыгнуть коснитесь экрана. Долгое нажатие - большой прыжок'

    color: (c) =>
        @tf._source.style.color = c

    hide: =>
        clearTimeout @hideTimer
        TweenMax.to @tf._source, 1, { opacity: 0, ease: Expo.easeOut, onComplete: @destroy }

module.exports = Help
