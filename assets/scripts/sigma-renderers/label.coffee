class LabelRenderer
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

    context.fillStyle   = '#0f0' #config.normal_color
    context.strokeStyle = config.stroke_color
    context.setLineWidth config.stroke_size * size

    @render_small context, x, y, width, height, size, padding, node

  render_small: (context, x, y, width, height, size, padding, node) ->
    context.beginPath()
    context.ellipse x,
                    y,
                    width / 2,
                    height / 2,
                    0,
                    0,
                    2 * Math.PI
    context.closePath()

    context.stroke()
    context.fill()

    @render_text context,
                node.data.name,
                config.center_text_size * size,
                x,
                y,
                width - padding * 2

  render_text: (context, text, size, x, y, width) ->
    context.font      = "#{size}pt #{config.font_family}"
    context.fillStyle = '#000'
    context.textAlign = 'center'
    context.textBaseline = 'middle'

    context.fillText text, x, y, width

window.sigma.canvas.nodes.label = (new LabelRenderer).render
