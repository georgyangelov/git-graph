class HistoryTrace
  constructor: (@sigma) ->
    @sigma.bind 'clickNode', @on_click

  on_click: ({data: {node, target}}) =>
    return if node.type != 'commit'

    @clear()
    @highlight node
    @sigma.refresh()

  highlight: (node) ->
    nodes   = [node]
    visited = {}

    while node = nodes.shift()
      node.highlight = true

      for id in node.data.parents
        continue if visited[id]
        visited[id] = true

        parent = @sigma.graph.nodes id

        if not parent
          console.log "Cannot find node #{parent_sha1}"
          continue

        nodes.push parent

  clear: ->
    nodes = @sigma.graph.nodes()

    for node in nodes
      node.highlight = false

window.Interactions ?= {}
window.Interactions.HistoryTrace = HistoryTrace
