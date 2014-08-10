class LabelRenderer
  config =
    stroke_color: '#000'
    stroke_size:  0.1
    padding:      0

    normal_color: '#0e0'
    remote_color: '#cfc'
    head_color:   '#ee0'
    tag_color:    '#61caff'

    font_family:      'Arial'
    center_text_size:  0.3

    details_size: 70

  render: (node, context, settings) =>
    prefix  = settings 'prefix' || ''
    size    = node[prefix + 'size']
    x       = node[prefix + 'x']
    y       = node[prefix + 'y']
    width   = size * 2.5
    height  = size
    padding = config.padding * size

    context.fillStyle = if node.data.type == 'head'
                          config.head_color
                        else if node.data.name.indexOf('/') > 0
                          config.remote_color
                        else if node.data.type == 'tag'
                          config.tag_color
                        else
                          config.normal_color

    context.strokeStyle = config.stroke_color
    context.setLineWidth  config.stroke_size * size

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
                node.data.name[node.data.name.lastIndexOf('/')+1..],
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
