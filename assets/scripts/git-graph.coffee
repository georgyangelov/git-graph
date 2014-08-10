class GitGraph
  config =
    step:
      x: 40 * 3
      y: 50

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

  load: ->
    $.getJSON 'history.json', (history) =>
      $.getJSON 'refs.json', (labels) =>
        @import history, labels

  import: (history, refs) =>
    nodes  = new SigmaNodeImport  @sigma, history
    labels = new SigmaLabelImport @sigma
    edges  = new SigmaEdgeImport  @sigma, history

    start_commits = (target for name, {target} of refs)

    nodes.import  0, 0, config.step.x, config.step.y, start_commits
    labels.import refs
    edges.import  0, 0, config.step.x, config.step.y, start_commits

    @sigma.refresh()

window.git_graph = new GitGraph document.getElementById('container')
window.git_graph.load()
