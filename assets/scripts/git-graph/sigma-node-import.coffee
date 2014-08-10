class SigmaNodeImport
  constructor: (@sigma, @history) ->

  import: (x, y, step_x, step_y, start_ids) ->
    queue = new PriorityQueue
      strategy: PriorityQueue.BinaryHeapStrategy,
      comparator: (a, b) ->
        r = b.commit.timestamp - a.commit.timestamp
        r = Math.abs(a.column) - Math.abs(b.column) if r is 0
        r

    added   = {}
    columns = {}

    start_ids = [start_ids] if typeof start_ids is 'string'

    for sha1, index in start_ids
      columns[index] = true
      queue.queue
        column: index
        commit: @history[sha1]

    while queue.length
      {commit, column} = queue.dequeue()

      columns[column] = false

      continue if added[commit.sha1]
      added[commit.sha1] = true

      @add_commit column * step_x, y, commit
      y += step_y

      for parent_sha1, i in commit.parents
        parent = @history[parent_sha1]

        console.log 'Cannot find commit', parent_sha1 unless parent?

        queue.queue
          column: @nearest_column columns, column
          commit: parent

  nearest_column: (columns, current) ->
    delta     = 0
    delta_abs = 0

    while true
      if not columns[current + delta_abs]
        delta = delta_abs
        break

      if not columns[current - delta_abs]
        delta = -delta_abs
        break

      delta_abs++

    columns[current + delta] = true

    current + delta

  add_commit: (x, y, commit) ->
    @sigma.graph.addNode
      id: commit.sha1
      x: x
      y: y
      size: 20
      type: 'commit'
      data: commit

window.SigmaNodeImport = SigmaNodeImport
