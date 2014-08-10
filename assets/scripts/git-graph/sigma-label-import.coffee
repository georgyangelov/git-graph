class SigmaLabelImport
  config =
    offset:
      x: 50,
      y: 0
    stack:
      y: -25

  constructor: (@sigma) ->

  import: (labels) ->
    for name, {type, target} of labels
      commit = @sigma.graph.nodes(target)

      unless commit
        console.error 'Provided label for unadded commit node'
        continue

      commit.data.labels ?= []

      offset_y = 0
      offset_y = config.stack.y * commit.data.labels.length if commit.data.labels.length > 0

      node = @add_label commit.x + config.offset.x,
                        commit.y + config.offset.y + offset_y,
                        name,
                        target,
                        type

      commit.data.labels.push node

  add_label: (x, y, name, target, type) ->
    id = @get_id name

    node = @sigma.graph.addNode
      id: id
      x: x
      y: y
      size: 20
      type: 'label'
      data:
        name:   name
        target: target
        type:   type

    @sigma.graph.addEdge
      id: "link-#{id}"
      source: id,
      target: target,
      size: 1

    node

  get_id: (name) -> "label-#{name}"

window.SigmaLabelImport = SigmaLabelImport
