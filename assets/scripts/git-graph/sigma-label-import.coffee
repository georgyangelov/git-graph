class SigmaLabelImport
  config =
    offset:
      x: 50,
      y: -50

  constructor: (@sigma) ->

  import: (labels) ->
    for name, {type, target} of labels
      commit = @sigma.graph.nodes(target)

      unless commit
        console.error 'Provided label for unadded commit node'
        continue

      @add_label commit.x + config.offset.x,
                 commit.y + config.offset.y,
                 name,
                 target,
                 type

  add_label: (x, y, name, target, type) ->
    id = "label-#{name}->#{target}"

    @sigma.graph.addNode
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

window.SigmaLabelImport = SigmaLabelImport
