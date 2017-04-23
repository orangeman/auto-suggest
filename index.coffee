module.exports = (div, autosuggest, defaultValue, onSelect) ->
  return unless div
  suggest = div.getElementsByClassName("suggest")[0]
  hide = () -> suggest.style.display = "none"
  show = () -> suggest.style.display = "block" unless suggest.innerHTML == ""
  input = div.getElementsByTagName("input")[0]
  input.value = defaultValue if defaultValue
  div.value = titleCase input.value?.split(",")?[0]?.trim()
  input.onblur = () -> setTimeout (() -> hide()), 300
  input.onclick = () ->
    if suggest.style.display == "none"
      show()
    #else hide()
  #input.select()
  slt = null
  text = ""
  select = (s) ->
    input.value = s.textContent if s
    div.value = titleCase input.value.split(",")[0].trim() if s
    text = s.textContent if s
    onSelect(text) if onSelect
    slt?.className = ""
    slt = null
    hide()
  suggest.onclick = (e) ->
    el = e.target
    if el.tagName != "A"
      if (el = el.parentNode).tagName != "A"
        return
    select el
  input.onkeydown = (e) ->
    switch k = e.charCode || e.keyCode || 0
      when 27 # ESC
        hide()
      when 13 # ENTER
        select slt
      when 38 # UP
        e.preventDefault()
        slt?.className = ""
        slt = slt?.previousSibling
        return hide() unless slt
        slt.className = "selected"
        if slt.offsetTop - suggest.scrollTop < slt.offsetHeight
          suggest.scrollTop = slt.offsetTop - slt.offsetHeight - 16
      when 40 # DOWN
        if !slt
          slt = suggest.firstChild
        else
          slt.className = ""
          slt = slt.nextSibling if slt.nextSibling
        slt?.className = "selected"
        suggest.scrollTop = slt?.offsetTop - suggest.offsetHeight * 1.03
        show()
      when 37 # LEFT
        return
      when 39 # RIGHT
        return
      when 33 # PAGE UP
        return
      when 34 # PAGE DOWN
        return
      when 35 # POS1
        return
      when 36 # END
        return
      when 91 # SUPER
        return
      when 93 # MENU
        return
      when 225 # ALT GR
        return
      when 20 # SHIFT
        return
      when 17 # STRG
        return
      when 18 # ALT
        return
      when 16 # SHIFT
        return
      when 9 # TAB
        select slt
      else
        #keydownDelayed()
        text = "" if !text || k == 70 # delete all?
        start = input.selectionStart
        end = input.selectionEnd
        if k == 8 # BACKSPACE
          start = start - 1 if start == end
          text = text.slice(0, start) + text.slice end
        else if k == 46 # DEL
          end = end + 1 if start == end
          text = text.slice(0, start) + text.slice end
        else #CHARACTER
          text = text.slice(0, start) + String.fromCharCode(k).toLowerCase() + text.slice end
        text = titleCase text
        #console.log "PRESS key=" + String.fromCharCode(k) + " code=" + e.keyCode + " text=" + text + "   caret " + input.selectionStart
        if text.length > 0
          autosuggest text, render
        else hide()
    true

  input.oninput = (e) ->
    if text.toLowerCase() != input.value.toLowerCase()
      text = titleCase input.value
      if text.length > 0
        autosuggest text, render
      else
        hide()


  render = (names) ->
    if names.length == 0 || names[0] == ""
      suggest.innerHTML = ""
      return hide()
    else
      suggest.innerHTML =
      names.map((rest) ->
        "<a>#{text}<span>#{rest}</span></a>"
      ).join('')
      show()
      slt = null

  titleCase = (str) ->
    if str.length > 0
      str[0].toUpperCase() + str[1..str.length-1]
    else ""

  onselect: (fun) -> onSelect = fun

cumulativeDelayed = () ->
  tld = null
  args = Array.prototype.slice.call(arguments)
  fn = args.shift()
  timeout = args.shift()
  () ->
    _args = args.concat(Array.prototype.slice.call(arguments))
    clearTimeout tid if tid
    tid = setTimeout (() -> fn.apply(null, _args)), timeout
