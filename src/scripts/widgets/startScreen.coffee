Widget = require './widget.coffee'
utils = require '../shared/utils.coffee'
TweenMax = require 'gsap/umd/TweenMax'
TimeLineMax = require 'gsap/umd/TimeLineMax'

class StartScreen extends Widget

    constructor: ( element, @mute = null ) ->
        super 'alabom-game-style-empty'
        @appendTo element
        @_source.style.display = 'none'

    start: ( @cb ) =>
        console.log 'start'
        @_source.style.display = ''
        @_source.style.opacity = 0
        TweenMax.to @_source, 1, {opacity: 1, delay: 0.2, ease: Quad.easeOut }

        @mute.hide()

        @bg = new Widget 'alabom-game-start-screen-bg'
        @bg.appendTo @

        @text = new Widget 'alabom-game-start-screen-text'
        @text.appendTo @

        @button = new Widget 'alabom-game-start-screen-button'
        @button.appendTo @

        @t = new TimeLineMax {repeat: -1}
        @t.add TweenMax.to @button._source, 1, {opacity: .5, ease: Expo.easeInOut }
        @t.add TweenMax.to @button._source, 1, {opacity: 1, ease: Expo.easeInOut }

        TweenMax.to @text._source, 0, {rotation: -4 }
        @t2 = new TimeLineMax {repeat: -1}
        @t2.to @text._source, 2, {rotation: 4, ease: Quad.easeInOut }
        @t2.to @text._source, 2, {rotation: -4, ease: Quad.easeInOut }

        @button._source.addEventListener 'mouseover', @buttonOver
        @button._source.addEventListener 'mouseout', @buttonOut
        @button._source.addEventListener 'click', @buttonClick

    buttonOver: =>
        TweenMax.to @button._source, 2, { scale: 1.5, ease: Elastic.easeOut }

    buttonOut: =>
        TweenMax.to @button._source, .5, { scale: 1, ease: Quad.easeInOut }

    buttonClick: =>
        @button._source.removeEventListener 'mouseover', @buttonOver
        @button._source.removeEventListener 'mouseout', @buttonOut
        @button._source.removeEventListener 'click', @buttonClick
        @button._source.style.cursor = 'default'
        @t.pause()
        TweenMax.to @button._source, 1, { scale: 10, opacity: 0, rotation: 90, ease: Quad.easeOut }
        TweenMax.to @_source, 1, {opacity: 0, delay: 0.2, ease: Quad.easeOut, onComplete: @finish }

    finish: =>
        @_source.style.display = 'none'
        @bg.destroy()
        @text.destroy()
        @button.destroy()

        @cb()



module.exports = StartScreen
