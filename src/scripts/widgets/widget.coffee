utils = require '../shared/utils.coffee'
EventEmitter = require('events').EventEmitter

##
# Base widget class
# @uses utils
class Widget extends EventEmitter
    ##
    # Widget DOM node
    # @property _source
    # @type Element
    # @api private

    ##
    # Visibility
    # @property visible
    # @type Boolean

    ##
    # @param {String} [type="div"] widget type
    # @param {String|Array<String>} [classNames="tvz-widget"] class name(s) that will be added to widget
    # @param {Boolean} [visible=true]
    constructor: ( classNames = 'widget', @visible = true, id = "", attributes = {}, element = null, type = 'div' ) ->
        super()

        if element
            @_source = document.getElementById element
        else
            @_source = document.createElement type.toLowerCase()

        if typeof classNames is 'string'
            @addClass classNames
        else
            @addClass className for className in classNames

        Object.keys(attributes).forEach (key) =>
            @_source.setAttribute key, attributes[key]

        if id then @setId id

        if not @visible
            @_source.style.display = 'none'
            @_source.style.opacity = 0

    ##
    # Append target to widget as child
    # @param {Widget} target widget that will be appended
    # @chainable
    append: (target) =>
        @_source.appendChild target._source
        @

    ##
    # Append widget to target as child
    # @param {Widget} target widget that will be used as container
    # @chainable
    appendTo: (target) =>
        target._source.appendChild @_source
        @

    appendToBefore: (target, elem) =>
        target._source.insertBefore @_source, elem._source
        @

    setId: (id) =>
        @_source.id = id
        @

    ##
    # Add class name to widget
    # @param {String} c class name
    # @chainable
    addClass: (c) =>
        utils.addClass @_source, c
        @

    ##
    # Remove class name
    # @param {String} c class name
    # @chainable
    removeClass: (c) =>
        utils.removeClass @_source, c
        @

    ##
    # Toggle widget's class name
    # @param {String} c class name
    # @chainable
    toggleClass: (c) =>
        if @_source.className.indexOf(c) > -1
            @removeClass c
        else
            @addClass c

    destroy: =>
        @_source.parentNode.removeChild @_source

    show: =>
        @_source.style.display = ''

    hide: =>
        @_source.style.display = 'none'

    ##
    # Merge class names for custom Widget constructor
    # @param {String|Array<String>} [classNames=""] outer class names
    # @param {String} [baseClassName=""] base widget class name
    # @return {Array} class name(s)
    @mergeClassNames: (classNames = '', baseClassName = '') =>
        if classNames? and classNames
            if typeof classNames is 'string'
                [baseClassName, classNames]
            else
                classNames.push baseClassName
                classNames
        else
            [baseClassName]

module.exports = Widget
