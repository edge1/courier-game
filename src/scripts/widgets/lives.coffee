utils = require '../shared/utils.coffee'
Widget = require './widget.coffee'
TweenMax = require 'gsap/umd/TweenMax'
TimeLineMax = require 'gsap/umd/TimeLineMax'

class Lives extends Widget

    constructor: ( classNames = 'widget', visible = true, id = "", attributes = {}, element = null, type = 'div' ) ->
        super classNames



        # star = new Widget 'alabom-game-engine-common-lives-heart'
        # star.appendTo @
        @livesArr = []


    set: (n) =>
        i = 0
        while i < @livesArr.length
            h = @livesArr[i]
            if h.h1 then h.h1.destroy()
            if h.h2 then h.h2.destroy()
            i++

        @livesArr = []

        i = 0
        @_source.style.right = 46 * n + 26 + 'px'
        while i < n
            h = new Widget 'alabom-game-engine-common-lives-heart-live'
            h.appendTo @
            h._source.style.left = 46 * i + 'px'
            @livesArr.push { h1: h }
            i++

        @maxLives = n
        @lives = n


    lost: =>
        if @lives > 0
            @lives--
            h2 = new Widget 'alabom-game-engine-common-lives-heart-dead'
            h2.appendToBefore @, @livesArr[@lives].h1
            h2._source.style.left = 46 * @lives + 'px'
            @livesArr[@lives].h2 = h2
            TweenMax.to @livesArr[@lives].h1._source, 1, { bottom: '30px', ease: Power1.easeIn, opacity: 0, onComplete: -> @target.parentNode.removeChild @target }
            @livesArr[@lives].h1 = null

    extra: =>
        if @lives < @maxLives
            h1 = new Widget 'alabom-game-engine-common-lives-heart-live'
            h1.appendTo @
            h1._source.style.left = 46 * @lives + 'px'
            h1._source.style.opacity = 0
            @livesArr[@lives].h1 = h1
            h2 = @livesArr[@lives].h2
            @livesArr[@lives].h2 = null
            t = new TimeLineMax
            t.add ( TweenMax.to h2._source, .5, { opacity: 0, ease: Power1.easeIn, onComplete: -> @target.parentNode.removeChild @target } )
            t.add ( TweenMax.to h1._source, .5, { opacity: 1, ease: Power1.easeIn } )
            @lives++





module.exports = Lives
