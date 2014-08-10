class SigmaNodeImport
  constructor: (@sigma, @history) ->

  import: (x, y, step_x, step_y, start_ids) ->
    queue = new PriorityQueue
      strategy: PriorityQueue.BinaryHeapStrategy,
      comparator: (a, b) ->
        r = b.commit.timestamp - a.commit.timestamp

        return r  if r != 0
        return -1 if b.column is null
        return 1  if a.column is null

        return Math.abs(a.column) - Math.abs(b.column)

    visited = {}
    added   = {}
    columns = {}

    start_ids = [start_ids] if typeof start_ids is 'string'

    for sha1, index in start_ids
      queue.queue
        column: null
        commit: @history[sha1]

    while queue.length
      {commit, column} = queue.dequeue()

      if column is null
        closest = 0

        for index, available of columns
          if available
            closest = parseInt index, 10
            break

        column = @nearest_column columns, closest

      columns[column] = false

      continue if added[commit.sha1]
      added[commit.sha1] = true

      @add_commit column * step_x, y, commit
      y += step_y

      for parent_sha1, i in commit.parents
        parent = @history[parent_sha1]

        console.log 'Cannot find commit', parent_sha1 unless parent?

        continue if visited[parent.sha1]
        visited[parent.sha1] = true

        queue.queue
          column: @nearest_column columns, column
          commit: parent

  nearest_column: (columns, current) ->
    delta     = 0
    delta_abs = 0

    while true
      if not columns[current + delta_abs] and not columns[current - delta_abs]
        delta = if current <= 0 then delta_abs else -delta_abs
        break

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
