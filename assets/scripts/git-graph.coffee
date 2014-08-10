class GitGraph
  config =
    step:
      x: 40 * 3
      y: 40

  constructor: (@container) ->
    @sigma = new sigma
      renderers: [{
        container: @container,
        type:      'canvas'
      }],

      settings:
        drawLabels:     false
        enableHovering: false
        maxNodeSize:    30
        maxEdgeSize:    30
        autoRescale:    false

        nodesPowRatio: 0.9
        edgesPowRatio: 1

  load: (url) ->
    $.getJSON url, @import

  import: (history) =>
    nodes = new SigmaNodeImport(@sigma, history)
    edges = new SigmaEdgeImport(@sigma, history)

    nodes.import 0, 0, config.step.x, config.step.y, Object.keys(history)[0]
    edges.import 0, 0, config.step.x, config.step.y, Object.keys(history)[0]

    @sigma.refresh()

window.git_graph = new GitGraph document.getElementById('container')
window.git_graph.load 'history.json'
