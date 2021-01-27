##
# Utility functions
# @module utils
# @namespace shared

##
# Get environment
# @return {String} environment ID (android|iphone|ipad|desktop)
exports.environment = ->
    # (navigator.userAgent.match(/(android|iphone|ipad|linux)/i) or ['default'])[0].toLowerCase()
    # (navigator.userAgent.match(/(android|iphone|ipad)/i) or ['default'])[0].toLowerCase()
    (navigator.userAgent.match(/(android|iphone|ipad)|Macintosh(?!(?=.*Chrome))(?=.*Safari)/i) or ['default'])[0].toLowerCase()

# exports.macSafari = ->
#     (navigator.userAgent.match(/Macintosh(?!(?=.*Chrome))(?=.*Safari)/i) or ['default'])[0].toLowerCase()











# Gets the browser name or returns an empty string if unknown.
# This function also caches the result to provide for any
# future calls this function has.
# @returns {string}
exports.browser = ->
    # Return cached result if avalible, else get result then cache it.
    # if browser::_cachedResult
    #     browser::_cachedResult
    # else
    # Opera 8.0+
    isOpera = ! !window.opr and ! !opr.addons or ! !window.opera or navigator.userAgent.indexOf(' OPR/') >= 0
    # Firefox 1.0+
    isFirefox = typeof InstallTrigger != 'undefined'
    # Safari 3.0+ "[object HTMLElementConstructor]"
    isSafari = /constructor/i.test(window.HTMLElement) or ((p) ->
      p.toString() == '[object SafariRemoteNotification]'
    )(!window['safari'] or safari.pushNotification)
    # Internet Explorer 6-11
    isIE = false or ! !document.documentMode
    # Edge 20+
    isEdge = !isIE and ! !window.StyleMedia
    # Chrome 1+
    isChrome = ! !window.chrome and ! !window.chrome.webstore
    # Blink engine detection
    isBlink = (isChrome or isOpera) and ! !window.CSS

    # browser::_cachedResult =
    if isOpera then 'opera' else if isFirefox then 'firefox' else if isSafari then 'safari' else if isChrome then 'chrome' else if isIE then 'ie' else if isEdge then 'edge' else 'unknown'

# exports.homeSite = ->
#     /www.tvzavr.ru|www.ruskino.net|staging.tvzavr.ru|192.168.2|192.168.3/.test(document.location.href)

exports.unique = (arr) ->
    obj = {}
    i = 0
    while i < arr.length
        str = arr[i]
        obj[str] = true
        # запомнить строку в виде свойства объекта
        i++
    Object.keys obj


exports.objCopyJson = (obj) ->
    JSON.parse(JSON.stringify(obj));

##
# Add class to element
# @param {Element} o element
# @param {String} c class name
# @return {String} element's final className value
# @memberOf utils
exports.addClass = (o, c) ->
    re = new RegExp '(^|\\s)' + c + '(\\s|$)', 'g'

    if not re.test o.className
        o.className = (o.className + ' ' + c).replace(/\s+/g, ' ').replace(/(^ | $)/g, '')
    else
        o.className

##
# Remove class from element
# @param {Element} o element
# @param {String} c class name
# @return {String} element's final className value
# @memberOf utils
exports.removeClass = (o, c) ->
    re = new RegExp '(^|\\s)' + c + '(\\s|$)', 'g'

    o.className = o.className.replace(re, '$1').replace(/\s+/g, ' ').replace(/(^ | $)/g, '')

##
# Get element position X and Y coordinates
# @param {Element} el DOM element
# @return {Object} position
# @returnprop {Number} top Y coordinate
# @returnprop {Number} left X coordinate
# @memberOf utils
exports.getElementCoords = (el) ->
    box = el.getBoundingClientRect() if el.getBoundingClientRect and el.parentNode
    {top: 0, left: 0} if not box

    doc = document.documentElement
    body = document.body

    clientLeft = doc.clientLeft or body.clientLeft or 0
    scrollLeft = window.pageXOffset or body.scrollLeft
    left = box.left + scrollLeft - clientLeft

    clientTop = doc.clientTop or body.clientTop or 0
    scrollTop = window.pageYOffset or body.scrollTop
    top = box.top + scrollTop - clientTop

    {
        top: top
        left: left
    }

##
# Get pointer position in element
# @param {Element} el DOM element
# @param {Event} event Event object
# @return {Object} position
# @returnprop {Number} y Y coordinate
# @returnprop {Number} x X coordinate
# @memberOf utils
exports.getPointerPos = (el, event) ->
    box = exports.getElementCoords(el)
    boxW = el.offsetWidth
    boxH = el.offsetHeight

    boxY = box.top
    boxX = box.left
    pageY = event.pageY
    pageX = event.pageX

    if event.changedTouches
        pageY = event.changedTouches[0].pageY
        pageX = event.changedTouches[0].pageX

    {
        y: Math.max(0, Math.min(1, ((boxY - pageY) + boxH) / boxH))
        x: Math.max(0, Math.min(1, (pageX - boxX) / boxW))
    }


exports.getStyleValueNumber = (elem, prop) ->
    Number( String( window.getComputedStyle( elem, null ).getPropertyValue( prop ) ).replace 'px', '' )

##
# Wrapper for setTimeout() function (for CoffeeScript)
# @param {Number} delay delay in ms
# @param {Function} cb callback
# @return {Number} timeout ID
# @memberOf utils
exports.timeout = (delay, cb) ->
    setTimeout cb, delay

##
# Wrapper for setInterval() function (for CoffeeScript)
# @param {Number} interval delay in ms
# @param {Function} cb callback
# @return {Number} interval ID
# @memberOf utils
exports.interval = (interval, cb) ->
    setInterval cb, interval


##
# Возвращает host от урла
# Например http://www.tvzavr.ru/
# Вернет www.tvzavr.ru
exports.urlHost = (url) ->
    (url.split '/')[2]

##
# Возвращает host от урла
# Например http://www.tvzavr.ru/
# Вернет tvzavr.ru
exports.urlHost2 = (url) ->
    (url.split '/')[2].replace 'www.', ''

##
# Возвращает host от урла
# Например https://www.tvzavr.ru/films/Elki-1914
# Вернет https://www.tvzavr.ru
exports.urlHost3 = (url) ->
    (url.split '/')[0] + '//'+ (url.split '/')[2]

##
# Возвращает содержимое перменной из урла
# например из урла http://www.tvzavr.ru?test=1
# getUrlValue('test') вернет 1
exports.getUrlValue = (name, url) ->
  if !url
      url = window.location.href
  name = name.replace(/[\[\]]/g, '\\$&')
  regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)')
  results = regex.exec(url)
  if !results
      return null
  if !results[2]
      return ''
  decodeURIComponent results[2].replace(/\+/g, ' ')

##
# Return time in string format "HH:MM:ss"
# @param {Number} time time in seconds
# @return {String} formatted time
# @memberOf utils
exports.formatTime = (time = 0) ->
    time = 0 if time is Infinity
    time = Math.ceil time
    hours = Math.floor time / 3600
    minutes = Math.floor( time - (hours * 3600) ) / 60
    seconds = time - (hours * 3600) - (minutes * 60)

    hours = "0#{hours}" if hours < 10
    minutes = "0#{minutes}" if minutes < 10
    seconds = "0#{seconds}" if seconds < 10

    "#{hours}:#{minutes}:#{seconds}"

##
# Merge source objects properties
# @param {Object} [sources...] source objects to merge
# @return {Object} merged object
# @memberOf utils
exports.merge = (sources...) ->
    target = {}

    _merge = (_target = {}, _source = {}) ->
        for key, value of _source
            continue if not _source.hasOwnProperty key

            if Object::toString.call(value) is '[object Object]'
                _target[key] = _merge _target[key], value
                continue

            _target[key] = value

        _target

    _merge target, source for source in sources
    target

##
# Записать переменную в локальное хранилище
# @param {String} _name имя переменной
# @param {String} _value значение переменной
# @return {String} значение переменной _value
exports.saveValue = ( _name, _value ) ->
    # debug.log 'settings.saveValue ', _name, _value
    if window.localStorage.getItem 'edgedevlocalstorage'
        locStor = JSON.parse window.localStorage.getItem 'edgedevlocalstorage'
    else
        locStor = {}

    locStor[_name] = _value

    s = JSON.stringify locStor
    window.localStorage.setItem 'edgedevlocalstorage', s

    _value

##
# Получить переменную из локального хранилища
# @param {String} _name имя переменной
# @param {String} _default_value значение по умолчанию в случае отсутствия
# @return {String} значение переменной _name либо _default_value
exports.restoreValue = ( _name, _default_value ) ->
    if window.localStorage.getItem 'edgedevlocalstorage'
        locStor = JSON.parse window.localStorage.getItem 'edgedevlocalstorage'
    else
        locStor = {}

    val = locStor[_name]
    if val is undefined
        val = _default_value
        @saveValue _name, _default_value

    val

##
# Получить куку по имени
# @param {String} name имя куки
# @return {String} значение куки, либо undefined
exports.getCookie = (name) ->
    matches = document.cookie.match(new RegExp('(?:^|; )' + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + '=([^;]*)'))
    if matches then decodeURIComponent(matches[1]) else undefined

##
# Установить куку
# @param {String} name имя куки
# @param {String} value значение куки
# @param {Object} options параметры:
#   expires Время истечения cookie. Интерпретируется по-разному, в зависимости от типа:
#     Число – количество секунд до истечения. Например, expires: 3600 – кука на час.
#     Объект типа Date – дата истечения.
#     Если expires в прошлом, то cookie будет удалено.
#     Если expires отсутствует или 0, то cookie будет установлено как сессионное и исчезнет при закрытии браузера.
#   path Путь для cookie.
#   domain Домен для cookie.
#   secure Если true, то пересылать cookie только по защищенному соединению.
exports.setCookie = (name, value, options) ->
    options = options or {}
    expires = options.expires
    if typeof expires == 'number' and expires
        d = new Date
        d.setTime d.getTime() + expires * 1000
        expires = options.expires = d
    if expires and expires.toUTCString
        options.expires = expires.toUTCString()
    value = encodeURIComponent(value)
    updatedCookie = name + '=' + value
    for propName of options
        updatedCookie += '; ' + propName
        propValue = options[propName]
        if propValue != true
            updatedCookie += '=' + propValue
    document.cookie = updatedCookie
    return

##
# Удалить куку по имени
# @param {String} name имя куки
exports.deleteCookie = (name) ->
    setCookie name, '', expires: -1
    return
