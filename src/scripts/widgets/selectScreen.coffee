Widget = require './widget.coffee'
utils = require '../shared/utils.coffee'
TweenMax = require 'gsap/umd/TweenMax'
TimeLineMax = require 'gsap/umd/TimeLineMax'

class SelectScreen extends Widget

    constructor: ( element, @mute = null ) ->
        super 'alabom-game-style-empty'
        @appendTo element
        @_source.style.display = 'none'

    start: ( @cb ) =>
        console.log 'select'
        @_source.style.display = ''
        @_source.style.opacity = 0
        TweenMax.to @_source, 1, {opacity: 1, delay: 0.2, ease: Quad.easeOut }

        @mute.show()

        @music = new Audio 'music/select.mp3'
        @music.volume = 0
        @music.play()
        @music.loop = true
        TweenMax.to @music, .5, { volume: if @mute.get() then .15 else 0 }
        @mute.addListener 'muted', @setMuted
        @mute.addListener 'unmuted', @setMuted

        @bg = new Widget 'alabom-game-select-screen-bg'
        @bg.appendTo @

        @text = new Widget 'alabom-game-select-screen-text'
        @text.appendTo @

        @city = new Widget 'alabom-game-select-screen-city', true, 'city'
        @city.appendTo @

        @china = new Widget 'alabom-game-select-screen-china', true, 'china'
        @china.appendTo @

        @winter = new Widget 'alabom-game-select-screen-winter', true, 'winter'
        @winter.appendTo @

        @summer = new Widget 'alabom-game-select-screen-summer', true, 'summer'
        @summer.appendTo @

        # TweenMax.to @text._source, 0, {scale: 1 }
        @t = new TimeLineMax {repeat: -1}
        @t.to @text._source, 1, {scale: .9, ease: Quad.easeInOut }
        @t.to @text._source, 1, {scale: 1, ease: Quad.easeInOut }

        @city._source.addEventListener 'mouseover', @buttonOver
        @city._source.addEventListener 'mouseout', @buttonOut
        @city._source.addEventListener 'click', @buttonClick

        @china._source.addEventListener 'mouseover', @buttonOver
        @china._source.addEventListener 'mouseout', @buttonOut
        @china._source.addEventListener 'click', @buttonClick

        @winter._source.addEventListener 'mouseover', @buttonOver
        @winter._source.addEventListener 'mouseout', @buttonOut
        @winter._source.addEventListener 'click', @buttonClick

        @summer._source.addEventListener 'mouseover', @buttonOver
        @summer._source.addEventListener 'mouseout', @buttonOut
        @summer._source.addEventListener 'click', @buttonClick

    setMuted: =>
        TweenMax.to @music, .5, { volume: if @mute.get() then .15 else 0 }

    buttonOver: (e) =>
        e.target.parentNode.removeChild e.target
        @._source.appendChild e.target
        TweenMax.to e.target, 2, { scale: 1.2, rotation: -20 + 40 * Math.random(), ease: Elastic.easeOut }

    buttonOut: (e) =>
        TweenMax.to e.target, 1, { scale: 1, rotation: 0, ease: Quad.easeInOut }

    buttonClick: (e) =>

        @city._source.removeEventListener 'mouseover', @buttonOver
        @city._source.removeEventListener 'mouseout', @buttonOut
        @city._source.removeEventListener 'click', @buttonClick

        @china._source.removeEventListener 'mouseover', @buttonOver
        @china._source.removeEventListener 'mouseout', @buttonOut
        @china._source.removeEventListener 'click', @buttonClick

        @winter._source.removeEventListener 'mouseover', @buttonOver
        @winter._source.removeEventListener 'mouseout', @buttonOut
        @winter._source.removeEventListener 'click', @buttonClick

        @summer._source.removeEventListener 'mouseover', @buttonOver
        @summer._source.removeEventListener 'mouseout', @buttonOut
        @summer._source.removeEventListener 'click', @buttonClick

        @mute.removeListener 'muted', @setMuted
        @mute.removeListener 'unmuted', @setMuted

        TweenMax.to e.target, 1, { scale: 10, opacity: 0, rotation: 90, ease: Quad.easeOut }
        TweenMax.to @_source, 1, {opacity: 0, delay: 0.2, ease: Quad.easeOut, onComplete: => @finish( e.target.id ) }

    finish: (loc) =>
        # console.log loc
        @_source.style.display = 'none'
        @bg.destroy()
        @text.destroy()
        @city.destroy()
        @china.destroy()
        @winter.destroy()
        @summer.destroy()

        TweenMax.to @music, .5, {volume: 0, onComplete: -> @target.pause}

        @cb loc


module.exports = SelectScreen
