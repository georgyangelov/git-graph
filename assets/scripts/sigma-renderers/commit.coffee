class CommitRenderer
  config =
    stroke_color: '#000'
    stroke_size:  0.1
    padding:      0.1

    normal_color: '#fff'
    merge_color:  '#e00'

    font_family:      'Arial'
    center_text_size:  0.3
    message_text_size: 0.1
    line_height:       1.3
    sha1_cutoff:       7

    details_size: 70

  render: (node, context, settings) =>
    prefix  = settings 'prefix' || ''
    size    = node[prefix + 'size']
    x       = node[prefix + 'x']
    y       = node[prefix + 'y']
    width   = size * 2
    height  = size
    padding = config.padding * size

    context.fillStyle   = config.normal_color
    context.strokeStyle = config.stroke_color
    context.setLineWidth config.stroke_size * size

    if size < config.details_size
      @render_small context, x, y, width, height, size, padding, node
    else
      @render_detailed context, x, y, width, height, size, padding, node

  render_small: (context, x, y, width, height, size, padding, node) ->
    context.fillStyle = config.merge_color if node.data.parents.length > 1

    context.beginPath()
    context.rect x - width / 2,
                 y - height / 2,
                 width,
                 height
    context.closePath()

    context.stroke()
    context.fill()

    @render_text context,
                node.data.sha1.substring(0, config.sha1_cutoff),
                config.center_text_size * size,
                x,
                y,
                width - padding * 2

  render_detailed: (context, x, y, width, height, size, padding, node) ->
    context.strokeStyle = config.merge_color if node.data.parents.length > 1

    context.beginPath()
    context.rect x - width / 2,
                 y - height / 2,
                 width,
                 height
    context.closePath()

    context.stroke()
    context.fill()

    if not node.fragmentMessage
      node.fragmentMessage = @fragmentText context, node.data.message, width - padding * 2

    @render_text context,
                 node.fragmentMessage,
                 config.message_text_size * size,
                 x,
                 y,
                 width - padding * 2

  render_text: (context, lines, size, x, y, width) ->
    lines = [lines] if typeof lines is 'string'

    context.font      = "#{size}pt #{config.font_family}"
    context.fillStyle = '#000'
    context.textAlign = 'center'
    context.textBaseline = 'alphabetic'

    height = lines.length * size * config.line_height

    for line, i in lines
      context.fillText line,
                       x,
                       y - height / 2 + (i + 1) * size * config.line_height

  fragmentText: (context, text, max_width) ->
    words = text.split ' '
    lines = []
    line  = ''

    return [text] if context.measureText(text).width < max_width

    while words.length > 0
      split = false

      while context.measureText(words[0]).width >= max_width
        last_symbol = words[0][-1..]
        words[0]    = words[0].slice(0, -1)

        if !split
          split = true
          words[1..1] = last_symbol
        else
          words[1] = last_symbol + words[1]

      if context.measureText(line + words[0]).width < max_width
        line += words.shift() + ' '
      else
        lines.push line
        line = ''

      lines.push line if words.length == 0

    lines


window.sigma.canvas.nodes.commit = (new CommitRenderer).render
