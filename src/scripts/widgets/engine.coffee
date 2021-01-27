Widget = require './widget.coffee'
Score = require './score.coffee'
Lives = require './lives.coffee'
Help = require './help.coffee'
Anchor = require './anchor.coffee'
utils = require '../shared/utils.coffee'
TweenMax = require 'gsap/umd/TweenMax'
TimeLineMax = require 'gsap/umd/TimeLineMax'
AES = require 'crypto-js/aes'

class Engine extends Widget

    constructor: ( element, @mute = null ) ->
        super 'alabom-game-style-empty'
        @appendTo element
        @_source.style.display = 'none'

    start: (@loc, @cb) =>
        console.log 'engine start'

        @_source.style.display = ''
        @_source.style.opacity = 0
        TweenMax.to @_source, 1, {opacity: 1, delay: 0.2, ease: Quad.easeOut }

        @key = 'H/-h*;=VSg=4Zn,<B$bYUy;[Ss,.yRm8'

        if window.alabomGameStart
            window.alabomGameStart()

        document.body.onkeydown = (e) ->
            e = e or window.event
            c = e.keyCode
            #Убирает эвент на стрелках, на pageDown, PageUp, Home, End
            if c is 32
                # if document.activeElement.tagName isnt 'INPUT' and document.activeElement.tagName isnt 'BUTTON'
                switch document.activeElement.tagName
                    when 'INPUT', 'BUTTON', 'TEXTAREA'
                        return
                    else
                        return false
            return

        switch @loc
            when 'city'
                @bg = new Widget 'alabom-game-engine-city-bg'
                @bg.appendTo @

                @bg2 = new Widget 'alabom-game-engine-city-bg2'
                @bg2.appendTo @

                @bg3 = new Widget 'alabom-game-engine-city-bg3'
                @bg3.appendTo @

                @greenLine = new Widget 'alabom-game-engine-city-green-line'
                @greenLine.appendTo @

                @layer3 = new Widget 'alabom-game-style-empty'
                @layer3.appendTo @

                @ground = new Widget 'alabom-game-engine-city-ground'
                @ground.appendTo @

                @music = new Audio 'music/city.mp3'

            when 'china'
                @bg = new Widget 'alabom-game-engine-china-bg'
                @bg.appendTo @

                @bg2 = new Widget 'alabom-game-engine-china-bg2'
                @bg2.appendTo @

                @bg3 = new Widget 'alabom-game-engine-china-bg3'
                @bg3.appendTo @

                @layer3 = new Widget 'alabom-game-style-empty'
                @layer3.appendTo @

                @ground = new Widget 'alabom-game-engine-china-ground'
                @ground.appendTo @

                @music = new Audio 'music/china.mp3'

            when 'summer'
                @bg = new Widget 'alabom-game-engine-summer-bg'
                @bg.appendTo @

                @bg2 = new Widget 'alabom-game-engine-summer-bg2'
                @bg2.appendTo @

                @bg3 = new Widget 'alabom-game-engine-summer-bg3'
                @bg3.appendTo @

                @layer3 = new Widget 'alabom-game-style-empty'
                @layer3.appendTo @

                @ground = new Widget 'alabom-game-engine-summer-ground'
                @ground.appendTo @

                @music = new Audio 'music/summer.mp3'

            when 'winter'
                @bg = new Widget 'alabom-game-engine-winter-bg'
                @bg.appendTo @

                @bg2 = new Widget 'alabom-game-engine-winter-bg2'
                @bg2.appendTo @

                @bg3 = new Widget 'alabom-game-engine-winter-bg3'
                @bg3.appendTo @

                @layer3 = new Widget 'alabom-game-style-empty'
                @layer3.appendTo @

                @ground = new Widget 'alabom-game-engine-winter-ground'
                @ground.appendTo @

                @music = new Audio 'music/winter.mp3'

        @music.volume = 0
        @music.play()
        @music.loop = true
        TweenMax.to @music, .5, { volume: if @mute.get() then .1 else 0 }
        @mute.addListener 'muted', @setMuted
        @mute.addListener 'unmuted', @setMuted

        @layer = new Widget 'alabom-game-style-empty'
        @layer.appendTo @

        @layer2 = new Widget 'alabom-game-style-empty'
        @layer2.appendTo @

        switch @loc
            when 'city'
                @player = new Widget 'alabom-game-engine-city-peng'

            when 'china'
                @player = new Widget 'alabom-game-engine-china-peng'

            when 'summer'
                @player = new Widget 'alabom-game-engine-summer-peng'

            when 'winter'
                @player = new Widget 'alabom-game-engine-winter-peng'

        @player.appendTo @
        # @anchor = new Anchor @player, false, 0, 3

        @score = new Score 'alabom-game-engine-common-score'
        @score.appendTo @
        if @loc is 'winter'
            @score.color '#8e85b5'

        @lives = new Lives 'alabom-game-engine-common-lives'
        @lives.appendTo @

        @help = new Help @
        if @loc is 'winter'
            @help.color '#8e85b5'

        @speed = 1.5
        # @speed = 0
        gravity = 500
        # gravity = 1000

        @totalWidth = 600
        @totalHeight = 400

        @paused = false

        updateInterval = 25
        # updateInterval = 16.66 #60fps
        # updateInterval = 33.33 #30fps
        # updateInterval = 66.66 #30fps

##################################################################################################################################
# Игрок
##################################################################################################################################

        @playerScore = 0
        @score.set @playerScore

        @playerLives = 3 #жизни
        @lives.set 3

        @playerStarNeedToCollectedForExtraLive = 100 # количество звезд для получения дополнительной жизни
        @playerStarCollectedForExtraLive = 0

        @playerScoreForOneStar = 5 # очков за одну звезду
        @playerScoreForLive = 1 # очков за нахождение в игре за каждые playerLiveScoreInterval секунд
        @playerLiveScoreTime = 0 # таймер
        @playerLiveScoreInterval = 10 # время за которые даются playerScoreForLive очков

        @playerDy = 0
        @playerYdefault = 107
        @playerY = @playerYdefault
        @playerJump = false
        @playerJumpPrepareDelay = 250
        @playerJumpPrepare = false
        @playerJumpPrepared = false
        @playerJumpStartSpeed = 300
        @playerJumpPreparedStartSpeed = 400
        @playerHits = false
        @playerFall = false
        @playerFallFlash = false
        @playerDifficulty = 0
        @playerDifficultyLevel2 = 1000 # количество отчков для перехода на уровень сложности 2
        @playerDifficultyLevel3 = 2000 # количество отчков для перехода на уровень сложности 3
        @playerDifficultyLevel4 = 3000 # количество отчков для перехода на уровень сложности 4
        @playerDifficultySpawnStars = [ 4, 4, 4, 4 ]
        @playerDifficultySpawnObstacles = [ 6, 5, 4, 3 ]
        @playerDifficultyObstaclesDelay = [ 7, 6, 5, 5 ]

        # @playerJumpStartSpeed = 400
        # @playerJumpPreparedStartSpeed = 600

        @playerJumpTimer = null
        @playerJumpPrepareTimer = null
        switch @loc
            when 'city'
                @playerSpriteMove = [ { px: 0, py: -18, h: 100 }, { px: -105, py: -17, h: 100} ]
                @playerSpriteJump = [ { px: -215, py: -17, h: 100 }, { px: -325, py: 0, h: 100 } ]
                @playerSpriteHit = [ { px: -171, py: -183, h: 100 }, { px: -274, py: -183, h: 100 } ]
                @playerSpriteFall = [ { px: -180, py: -324, h: 107 } ]
            when 'china'
                @playerSpriteMove = [ { px: 0, py: -16, h: 100 }, { px: 0, py: -17, h: 100 } ]
                @playerSpriteJump = [ { px: -105, py: -16, h: 100 }, { px: -205, py: 5, h: 100 } ]
                @playerSpriteHit = [ { px: -298, py: -16, h: 100 }, { px: -392, py: -16, h: 100 } ]
                @playerSpriteFall = [ { px: -502, py: -5, h: 107 } ]
            when 'summer'
                @playerSpriteMove = [ { px: 0, py: -16, h: 100 }, { px: 0, py: -17, h: 100 } ]
                @playerSpriteJump = [ { px: -111, py: -12, h: 100 }, { px: -221, py: 8, h: 100 } ]
                @playerSpriteHit = [ { px: -320, py: -19, h: 100, x: 24 }, { px: -446, py: -19, h: 100 } ]
                @playerSpriteFall = [ { px: -553, py: -14, h: 107 } ]
            when 'winter'
                @playerSpriteMove = [ { px: 0, py: -15, w: 97, h: 100 }, { px: 0, py: -16, h: 100 } ]
                @playerSpriteJump = [ { px: -109, py: -15, w: 100, h: 100 }, { px: -225, py: 8, w: 97, h: 100 } ]
                @playerSpriteHit = [ { px: -341, py: -16, h: 100 }, { px: -444, py: -16, w: 92, h: 100 } ]
                @playerSpriteFall = [ { px: -540, py: -7, h: 110 } ]

        @playerSpriteMoveStep = 0
        @playerSpriteHitStep = 0
        @setSprite @player, @playerSpriteMove[ 0 ]

        @playerOpacityAnimate = new TimeLineMax {paused: true}
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.25, { opacity: .5, ease: Expo.easeInOut } )
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.25, { opacity: .5, ease: Expo.easeInOut } )
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimate.add( TweenMax.to @player._source, 0.5, { opacity: 1, ease: Expo.easeInOut } )

        @playerOpacityAnimateLong = new TimeLineMax {paused: true}
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: .5, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: .5, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: .5, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.25, { opacity: 0, ease: Expo.easeInOut } )
        @playerOpacityAnimateLong.add( TweenMax.to @player._source, 0.5, { opacity: 1, ease: Expo.easeInOut } )

        @playerHitAnimate = new TimeLineMax {paused: true}
        @playerHitAnimate.add( TweenMax.to @player._source, 0.25, { left: '20px', ease: Expo.easeOut } )
        @playerHitAnimate.add( TweenMax.to @player._source, 1, { left: '42px', ease: Quad.easeInOut } )

        @playerHitAnimateSummer = new TimeLineMax {paused: true}
        @playerHitAnimateSummer.add( TweenMax.to @player._source, 0.25, { left: '2px', ease: Expo.easeOut } )
        @playerHitAnimateSummer.add( TweenMax.to @player._source, 1, { left: '42px', ease: Quad.easeInOut } )

        # @playerFallAnimate = new TimeLineMax {paused: true}
        # @playerFallAnimate.add( TweenMax.to @player._source, 1, { bottom: '0px', ease: Expo.easeIn } )

        @playerDeadAnimate = new TimeLineMax {paused: true}
        @playerDeadAnimate.add( TweenMax.to @player._source, 1, { left: '20px', ease: Expo.easeOut } )




        @playerAnimateMoveTimer = utils.interval 500, =>
            if not @paused
                if @speed > 0 and not @playerJump and not @playerJumpPrepare and not @playerJumpTimer and not @playerHits and not @playerFall
                    @setSprite @player, @playerSpriteMove[ @playerSpriteMoveStep ]
                    if ++ @playerSpriteMoveStep >= @playerSpriteMove.length then @playerSpriteMoveStep = 0
                # if @playerHit
                #     @setSprite @player, @playerSpriteHit[ @playerSpriteHitStep ]
                #     if @playerSpriteHitStep < @playerSpriteHit.length - 1 then @playerSpriteHitStep++
                    # if ++ @playerSpriteHitStep >= @playerSpriteHit.length
                    #     then @playerSpriteMoveStep = 0

##################################################################################################################################
# Слушатели
##################################################################################################################################

        window.addEventListener 'focus', @resume
        window.addEventListener 'blur', @pause
        document.addEventListener 'keydown', @keyDown
        document.addEventListener 'keyup', @keyUp
        if utils.environment() is 'default'
            @_source.addEventListener 'mousedown', @jumpKeyDown
            @_source.addEventListener 'mouseup', @jumpKeyUp
        else
            @_source.addEventListener 'touchstart', @jumpKeyDown
            @_source.addEventListener 'touchend', @jumpKeyUp

##################################################################################################################################
# Обработка движения
##################################################################################################################################

        bg2dx = 0
        bg3dx = 0
        groundDx = 0

        spawnTimeInterval = .4
        spawnTime = 0

        @spawnArr = []

        @spawnChargeArr = []

        @obstacleDelay = 0

        @time = new Date().getTime()
        @engineTimer = utils.interval updateInterval, =>
            if not @paused
                @oldTime = @time
                @time = new Date().getTime()
                deltaTime = @time - @oldTime
                deltaTime = ( updateInterval / 1000 ) * deltaTime / updateInterval

                if @speed > 0
                    bg2dx -= @speed * 5 * deltaTime
                    @bg2._source.style.cssText = 'background-position: ' + bg2dx + 'px' + ' bottom !important'

                    bg3dx -= @speed * 10 * deltaTime
                    @bg3._source.style.cssText = 'background-position: ' + bg3dx + 'px' + ' bottom !important'

                    groundDx -= @speed * 100 * deltaTime
                    @ground._source.style.cssText = 'background-position: ' + groundDx + 'px' +' !important'

                if @playerJump and not @playerFall
                    @playerY += @playerDy * deltaTime
                    @playerDy -= (gravity * deltaTime)
                    if @playerY < @playerYdefault
                        @playerY = @playerYdefault
                        @playerJump = false
                        if not @playerHits
                            @setSprite @player, @playerSpriteJump[ 0 ]
                        @playerJumpTimer = utils.timeout 250, =>
                            clearTimeout @playerJumpTimer
                            @playerJumpTimer = null
                            if not @playerJumpPrepared and not @playerHits
                                @setSprite @player, @playerSpriteMove[ @playerSpriteMoveStep ]

                    @player._source.style.bottom = @playerY + 'px'

                if @playerFall
                    @playerY += @playerDy * deltaTime
                    @playerDy -= (gravity * deltaTime)

                    @player._source.style.bottom = @playerY + 'px'

                px = 88
                py = @playerY + 50

                i = 0
                while i < @spawnArr.length
                    a = @spawnArr[i]
                    if a.speed and a.width
                        a.x -= @speed * a.speed * deltaTime
                        a.widget._source.style.left = a.x + 'px'
                        collected = false

                        if a.name is 'star'
                            if Math.pow( a.x + a.width / 2 - px, 2 ) + Math.pow( a.y + a.height / 2 - py, 2 ) < 2500
                                collected = true
                                @playerScore += @playerScoreForOneStar
                                @checkDifficulty()
                                if ++@playerStarCollectedForExtraLive >= @playerStarNeedToCollectedForExtraLive
                                    @playerStarCollectedForExtraLive = 0
                                    if @playerLives < 3
                                        @playerLives++
                                        @lives.extra()

                                @score.set @playerScore
                                if window.alabomGameScore
                                    try
                                        window.alabomGameScore AES.encrypt( @playerScoreForOneStar.toString(), @key ).toString()
                                    catch e
                                        try
                                            window.alabomGameScore @playerScoreForOneStar
                                        catch e

                                TweenMax.to a.widget._source, 0.5, { left: px - a.width / 2 + 'px', bottom: py - a.height / 2 + 'px', opacity: 0, onComplete: -> @target.parentNode.removeChild @target }

                        if not @playerHits and not @playerFallFlash
                            switch a.type
                                when 'obstacle'
                                    if Math.pow( a.x + a.width / 2 - px, 2 ) + Math.pow( a.y + a.height / 2 - py, 2 ) < a.radius
                                        a.type = ''
                                        @playerHits = true
                                        @lives.lost()
                                        if --@playerLives > 0
                                            if @loc is 'summer'
                                                @playerHitAnimateSummer.restart()
                                            else
                                                @playerHitAnimate.restart()
                                            @setSprite @player, @playerSpriteHit[ 0 ]
                                            utils.timeout 250, =>
                                                # @playerHits = false
                                                @setSprite @player, @playerSpriteMove[ @playerSpriteMoveStep ]
                                                @playerOpacityAnimateLong.restart()
                                                utils.timeout 2500, => #1750
                                                    @playerHits = false
                                        else
                                            @playerDeadAnimate.restart()
                                            @setSprite @player, @playerSpriteHit[ 1 ]
                                            @speed = 0
                                            @stop()
                                when 'pit'
                                    if @playerDy <= 0
                                        if Math.pow( a.x + a.width / 2 - px, 2 ) + Math.pow( a.y + a.height / 2 - py, 2 ) < a.radius
                                            a.type = ''
                                            @playerFall = true
                                            @lives.lost()
                                            if not @playerJump
                                                @playerDy = 0
                                                @playerJump = false
                                            @setSprite @player, @playerSpriteFall[ 0 ]
                                            if --@playerLives > 0
                                                utils.timeout 1000, =>
                                                    @playerY = @playerYdefault
                                                    @playerDy = 0
                                                    @player._source.style.bottom = @playerY + 'px'
                                                    @playerFall = false
                                                    @setSprite @player, @playerSpriteMove[ @playerSpriteMoveStep ]
                                                    @playerOpacityAnimate.restart()
                                                    @playerFallFlash = true
                                                    utils.timeout 1750, =>
                                                        @playerFallFlash = false
                                            else
                                                utils.timeout 1000, =>
                                                    @playerJump = false
                                                    @playerFall = false
                                                    @speed = 0
                                                    @stop()

                        if a.x < - a.width or collected
                            if not collected
                                a.widget.destroy()
                            # console.log 'destroy: ' + a.name + ', arr: ', @spawnArr.length - 1
                            a = null
                            @spawnArr.splice i, 1
                            i--
                    i++



##################################################################################################################################
# Спаун объектов
##################################################################################################################################

                @playerLiveScoreTime += @speed * deltaTime
                if @playerLiveScoreTime >= @playerLiveScoreInterval
                    @playerLiveScoreTime = 0

                    @playerScore += @playerScoreForLive
                    @checkDifficulty()
                    @score.set @playerScore
                    if window.alabomGameScore
                        try
                            window.alabomGameScore AES.encrypt( @playerScoreForLive.toString(), @key ).toString()
                        catch e
                            try
                                window.alabomGameScore @playerScoreForLive
                            catch e

                spawnTime += @speed * deltaTime
                # console.log spawnTime
                if spawnTime >= spawnTimeInterval
                    # console.log 'spawn time'
                    spawnTime -= spawnTimeInterval
                    if spawnTime > spawnTimeInterval then spawnTime = 0

                    if @loc is 'city'
                        if not Math.floor( 15 * Math.random() )
                            @spawnObject 'bush'

                        if not Math.floor( 15 * Math.random() )
                            @spawnObject 'bush2'

                    if not Math.floor( @playerDifficultySpawnObstacles[@playerDifficulty] * Math.random() ) and not @obstacleDelay #5
                        @obstacleDelay = @playerDifficultyObstaclesDelay[@playerDifficulty]
                        @obstacleHighDelay = 3

                        switch Math.floor( 4 * Math.random())
                            when 0
                                switch @loc
                                    when 'city'
                                        @spawnObject 'car'
                                    when 'china'
                                        @spawnObject 'dragon'
                                    when 'summer'
                                        @spawnObject 'ship'
                                    when 'winter'
                                        @spawnObject 'feltboots'
                            when 1
                                switch @loc
                                    when 'city'
                                        @spawnObject 'tree'
                                    when 'china'
                                        @spawnObject 'chinatree'
                                    when 'summer'
                                        @spawnObject 'whale'
                                    when 'winter'
                                        @spawnObject 'fir'
                            when 2
                                switch @loc
                                    when 'city'
                                        @spawnObject 'garbage'
                                    when 'china'
                                        @spawnObject 'cart'
                                    when 'summer'
                                        @spawnObject 'wave'
                                    when 'winter'
                                        @spawnObject 'snowman'
                            when 3
                                switch @loc
                                    when 'city'
                                        @spawnObject 'pit'
                                    when 'china'
                                        @spawnObject 'chinaPit'
                                    when 'summer'
                                        @spawnObject 'whirlpool'
                                    when 'winter'
                                        @spawnObject 'glacier'

                    a = @spawnChargeArr.shift()
                    if a?.name isnt 'star'
                        if not Math.floor( @playerDifficultySpawnStars[@playerDifficulty] * Math.random() ) #4
                            # console.log 'random star'
                            @spawnObject 'star'
                    else
                        # console.log 'charged star', a.y
                        @spawnObject 'star', a

                    if @obstacleDelay > 0 then @obstacleDelay--

                    if @obstacleHighDelay > 0 then @obstacleHighDelay--

                    # if a?.name is 'star'
                    #     if a.y is 139
                    #         skipObstacle = true

    setMuted: =>
        TweenMax.to @music, .5, { volume: if @mute.get() then .1 else 0 }

    checkDifficulty: =>
        if @playerScore >= @playerDifficultyLevel2 and @playerDifficulty is 0 then @playerDifficulty = 1
        if @playerScore >= @playerDifficultyLevel3 and @playerDifficulty is 1 then @playerDifficulty = 2
        if @playerScore >= @playerDifficultyLevel4 and @playerDifficulty is 2 then @playerDifficulty = 3

    spawnObject: (name, param = null ) =>
        a = undefined
        x = undefined
        y = undefined
        speed = undefined
        width = undefined
        height = undefined
        type = undefined
        radius = undefined

        switch name

            when 'fir', 'snowman', 'feltboots'
                a = new Widget 'alabom-game-engine-winter-' + name
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 2500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'glacier'
                a = new Widget 'alabom-game-engine-winter-glacier'
                a.appendTo @layer2
                x = @totalWidth
                type = 'pit'
                speed = 100
                radius = 12100
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'


            when 'ship'
                a = new Widget 'alabom-game-engine-summer-' + name
                a.appendTo @layer3
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 3500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'whale'
                a = new Widget 'alabom-game-engine-summer-' + name
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 3500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'wave'
                a = new Widget 'alabom-game-engine-summer-' + name
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 2500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'whirlpool'
                a = new Widget 'alabom-game-engine-summer-whirlpool'
                a.appendTo @layer2
                x = @totalWidth
                type = 'pit'
                speed = 100
                radius = 12100
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'dragon'
                a = new Widget 'alabom-game-engine-china-dragon'
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 3500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'chinatree', 'cart'
                a = new Widget 'alabom-game-engine-china-' + name
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 2500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'chinaPit'
                a = new Widget 'alabom-game-engine-china-pit'
                a.appendTo @layer2
                x = @totalWidth
                type = 'pit'
                speed = 100
                radius = 12100
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'bush', 'bush2'
                a = new Widget 'alabom-game-engine-city-' + name
                a.appendTo @layer
                x = @totalWidth
                speed = 100
                width = utils.getStyleValueNumber a._source, 'width'

            when 'car'
                a = new Widget 'alabom-game-engine-city-car'
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 3500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'tree', 'garbage'
                a = new Widget 'alabom-game-engine-city-' + name
                a.appendTo @layer2
                x = @totalWidth
                type = 'obstacle'
                speed = 100
                radius = 2500
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'pit'
                a = new Widget 'alabom-game-engine-city-pit'
                a.appendTo @layer2
                x = @totalWidth
                type = 'pit'
                speed = 100
                radius = 12100
                y = utils.getStyleValueNumber a._source, 'bottom'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'

            when 'star'
                a = new Widget 'alabom-game-engine-common-star'
                a.appendTo @layer2
                x = @totalWidth
                if param?.y
                    y = param.y
                else
                    if not @obstacleHighDelay
                        y1 = [ 139, 229, 312 ]
                    else
                        y1 = [ 229, 312 ]

                    y = y1[ Math.floor( y1.length * Math.random() ) ]
                speed = 100
                type = 'collect'
                width = utils.getStyleValueNumber a._source, 'width'
                height = utils.getStyleValueNumber a._source, 'height'
                if y is 139
                    # if @obstacleDelay > 0
                    #     @obstacleDelay ++
                    # else
                    if @obstacleDelay is 0
                        @obstacleDelay = 3
                # @spawnCharge 'star', 2, { y: y }
                if not param
                    @spawnChargeArr.push { name: 'star', y: y }
                    if not Math.floor( 3 * Math.random() ) then @spawnChargeArr.push { name: 'star', y: y }

        if a
            if x then a._source.style.left = x + 'px'
            if y then a._source.style.bottom = y + 'px'
            @spawnArr.push { name: name, widget: a, x: x, y: y, speed: speed, width: width, height: height, type: type, radius: radius }
            # console.log 'spawn: ' + name + ', arr:', @spawnArr.length

    # spawnCharge: (name, count, params) =>



##################################################################################################################################
# Обработка событий от игрока
##################################################################################################################################

    keyDown: (e) =>
        # console.log e.keyCode
        if e.keyCode is 32
            @jumpKeyDown()
            # e.preventDefault()
            # e.stopPropagation()

    keyUp: (e) =>
        if e.keyCode is 32
            @jumpKeyUp()
            # e.preventDefault()
            # e.stopPropagation()

    jumpKeyDown: (e) =>
        if @help
            @help.hide()
            @help = null
        if e? then e.preventDefault()
        if not @playerJumpPrepare and @playerLives > 0 and not @playerFall
            # console.log 'jumpKeyDown'
            @playerJumpPrepare = true

            clearTimeout @playerJumpTimer
            @playerJumpTimer = null

            @playerJumpPrepareTimer = utils.timeout @playerJumpPrepareDelay, =>
                @playerJumpPrepared = true
                clearTimeout @playerJumpPrepareTimer

                if not @playerJump
                    @setSprite @player, @playerSpriteJump[ 0 ]

    jumpKeyUp: (e) =>
        if e? then e.preventDefault()
        if not @playerJump and @playerLives > 0 and not @playerFall
            # console.log 'jumpKeyUp'

            clearTimeout @playerJumpTimer
            @playerJumpTimer = null

            clearTimeout @playerJumpPrepareTimer

            if @playerJumpPrepared
                @playerDy = @playerJumpPreparedStartSpeed
            else
                @playerDy = @playerJumpStartSpeed
            @playerY = @playerYdefault
            @playerJump = true
            @playerJumpPrepare = false
            @playerJumpPrepared = false
            @setSprite @player, @playerSpriteJump[ 1 ]
        else
            clearTimeout @playerJumpPrepareTimer
            @playerJumpPrepare = false


    setSprite: ( widget, obj ) ->
        widget._source.style.backgroundPosition = obj.px + 'px ' + obj.py + 'px'
        if obj.w?
            widget._source.style.width = obj.w + 'px'
        if obj.h?
            widget._source.style.height = obj.h + 'px'
        if obj.x?
            widget._source.style.left = obj.x + 'px'
        if obj.y?
            widget._source.style.bottom = obj.y + 'px'

    pause: =>
        @paused = true
        @music.pause()
        # console.log 'pause'

    resume: =>
        @paused = false
        @music.play()
        @time = @oldTime = new Date().getTime()
        # console.log 'resume'

    stop: =>
        console.log 'engine stop'

        utils.timeout 2000, =>

            TweenMax.to @_source, 1, { opacity: 0, delay: 0.2, ease: Quad.easeOut }

            utils.timeout 1200, =>
                @_source.style.display = 'none'

                @playerOpacityAnimate.kill()
                @playerHitAnimate.kill()

                clearInterval @engineTimer
                clearInterval @playerAnimateMoveTimer
                clearTimeout @playerJumpTimer
                clearTimeout @playerJumpPrepareTimer

                while @spawnArr.length > 0
                    a = @spawnArr[0]
                    a.widget.destroy()
                    @spawnArr.shift()
                    # console.log 'destroy: ' + a.name + ', arr: ', @spawnArr.length
                @spawnArr = null
                @spawnChargeArr = null

                @bg.destroy()
                @bg2.destroy()
                @bg3.destroy()
                @ground.destroy()
                @layer.destroy()
                @layer2.destroy()
                @layer3.destroy()
                @player.destroy()
                @score.destroy()
                @lives.destroy()

                if @loc is 'city'
                    @greenLine.destroy()

                window.removeEventListener 'focus', @resume
                window.removeEventListener 'blur', @pause
                document.removeEventListener 'keydown', @keyDown
                document.removeEventListener 'keyup', @keyUp
                if utils.environment() is 'default'
                    @_source.removeEventListener 'mousedown', @jumpKeyDown
                    @_source.removeEventListener 'mouseup', @jumpKeyUp
                else
                    @_source.removeEventListener 'touchstart', @jumpKeyDown
                    @_source.removeEventListener 'touchend', @jumpKeyUp

                if window.alabomGameEnd
                    try
                        window.alabomGameEnd AES.encrypt( @playerScore.toString(), @key ).toString()
                    catch e
                        try
                            window.alabomGameEnd @playerScore
                        catch r

                @mute.removeListener 'muted', @setMuted
                @mute.removeListener 'unmuted', @setMuted

                TweenMax.to @music, .5, {volume: 0, onComplete: -> @target.pause}

                document.body.onkeydown = null

                @cb()

module.exports = Engine
