class SigmaEdgeImport
  constructor: (@sigma, @history) ->

  import: (x, y, step_x, step_y, start_ids) ->
    start_ids = [start_ids] if typeof start_ids is 'string'

    added   = {}
    commits = (@history[sha1] for sha1 in start_ids)

    while commit = commits.shift()
      for parent_sha1 in commit.parents
        edge_id = "#{commit.sha1}->#{parent_sha1}"

        continue if added[edge_id]
        added[edge_id] = true

        if not @history[parent_sha1]
          console.log "Cannot find commit #{parent_sha1}"
          continue

        @add_commit_edge edge_id, commit.sha1, parent_sha1

        commits.push @history[parent_sha1]

  add_commit_edge: (id, id1, id2) ->
    @sigma.graph.addEdge
      id: id
      source: id1,
      target: id2,
      size: 1

window.SigmaEdgeImport = SigmaEdgeImport
