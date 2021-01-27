utils = require '../shared/utils.coffee'

class Debug

    constructor: ->

        @code = []
        @code.push [['d','в'], ['b','и'], ['g','п'], '1', 'debug1', {queue:0} ]
        @code.push [['s','ы'], ['a','ф'], ['v','м'], ['e','у'], ['l','д'], ['o','щ'], ['g','п'], 'savelog', {queue:0} ]
        @code.push [['s','ы'],['h','р'],['o','щ'],['w','ц'],['l','д'],['o','щ'],['g','п'], 'showlog', {queue:0} ]

        @arr = []
        @length = 5000

        @addListeners()

    addListeners: ->
        document.body.addEventListener 'keydown', (e) =>
            self = @
            @code.forEach (key) ->
                vars = key[key.length - 1]
                if e.key in key[vars.queue]
                    if ++ vars.queue is key.length - 2
                        self.match( key[key.length-2] )
                        vars.queue = 0
                else
                    if e.key in key[0]
                        vars.queue = 1
                    else
                        vars.queue = 0

    match: (value) ->
        switch value
            when 'debug1'
                alert 'debug1'
            when 'savelog'
                s = ''
                @arr.forEach (value) =>
                    s += value
                    s += '\r\n'
                @copyTextToClipboard s
                s = ''
                # alert 'its savelog!!!'
            when 'showlog'
                if not @popup or @popup.window.closed
                    @popup = window.open './debug', 'tvzavr player debug window', 'width=1000,height=700,scrollbars=no'
                    @popup.updatelog @arr


                # alert 'its showlog!!!'

    log: ->
        args = arguments
        v = ''
        i = 0
        Object.keys(args).forEach (key) ->
            v += args[key]
            if ++ i < args.length
                v += ', '

        console.log v
        @arr.push v
        if @arr.length >= @length
            @arr.shift()

        # if @popup and not @popup.window.closed
        #     @popup.log v

    copyTextToClipboard: (text) ->
        textArea = document.createElement 'textarea'
        textArea.style.position = 'fixed'
        textArea.style.top = 0
        textArea.style.left = 0
        textArea.style.width = '2em'
        textArea.style.height = '2em'
        textArea.style.padding = 0
        textArea.style.border = 'none'
        textArea.style.outline = 'none'
        textArea.style.boxShadow = 'none'
        textArea.style.background = 'transparent'
        textArea.value = text;
        document.body.appendChild textArea
        textArea.focus()
        textArea.select()

        try
            successful = document.execCommand 'copy'
            # msg = successful ? 'successful' : 'unsuccessful'
            # log( 'Copying text command was ', msg )
        catch er
            # log( 'Oops, unable to copy' )

        document.body.removeChild textArea

    ###
    # Метод выводит в лог любой объект или массив
    # o - объект или массив
    # t - количество пробелов в табуляции
    # p - количество пробелов в начальной табуляция
    ###
    data: (o, t = 2, p = 0) ->

        getSpace = (p) ->
            i = 0
            s = ''
            while i < p
                i++
                s += ' '
            s

        parseObject = (o, p) =>
            Object.keys(o).forEach (key) =>
                switch typeof o[key]
                    when 'object'
                        if Array.isArray o[key]
                            debug.log getSpace(p) + key + ' []'
                            parseArray o[key], p + t
                        else
                            if o[key] is null
                                debug.log getSpace(p) + key + ': ' + String(o[key])
                            else
                                debug.log getSpace(p) + key + ' {}'
                                parseObject o[key], p + t
                    when 'string', 'number', 'null', 'boolean', 'undefined'
                        debug.log getSpace(p) + key + ': ' + String(o[key])

        parseArray = (o, p) =>
            e = false
            o.forEach (key) =>
                if typeof key is 'object'
                    e = true

            if e
                i = 0
                o.forEach (key) =>
                    switch typeof key
                        when 'object'
                            if Array.isArray key
                                debug.log getSpace(p) + i + ': []'
                                parseArray key, p + t
                            else
                                if key is null
                                    debug.log getSpace(p) + i + ': ' + String(key)
                                else
                                    debug.log getSpace(p) + i + ' {}'
                                    parseObject key, p + t
                        when 'string', 'number', 'null', 'boolean', 'undefined'
                            debug.log getSpace(p) + i + ': ' + String(key)
                    i++

            else
                s = ''
                i = 0
                o.forEach (key) =>
                    if i++ > 0 then s += ', '
                    s += String( key )

                s = '[' + s + ']'

                debug.log getSpace(p) + s
        try
            if typeof o is 'object'
                if Array.isArray o
                    debug.log getSpace(p) + '[]'
                    parseArray o, p
                else
                    if o is null
                        debug.log getSpace(p) + o
                    else
                        debug.log getSpace(p) + '{}'
                        parseObject o, p
            else
                debug.log getSpace(p) + o
        catch er

        null


module.exports = new Debug()
