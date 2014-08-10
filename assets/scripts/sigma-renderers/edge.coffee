class EdgeRenderer
  config =
    color:         '#000'
    reverse_color: '#f00'
    width:         1

  render: (edge, source, target, context, settings) =>
    prefix = settings 'prefix' || ''
    size   = edge[prefix + 'size'] || 1
    start  =
      x: source[prefix + 'x']
      y: source[prefix + 'y']
    end    =
      x: target[prefix + 'x']
      y: target[prefix + 'y']

    context.strokeStyle = config.color
    context.strokeStyle = config.reverse_color if start.y > end.y
    context.lineWidth   = size * config.width

    context.beginPath()
    context.moveTo start.x, start.y
    context.lineTo end.x,   end.y
    context.closePath()

    context.stroke()

window.sigma.canvas.nodes.commit = (new EdgeRenderer).render
