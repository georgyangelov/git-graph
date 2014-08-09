require 'rugged'

class GitGraph
  def initialize(repository_path)
    @repository = Rugged::Repository.new repository_path
  end

  def history(start_refs)
    walker = Rugged::Walker.new @repository

    walker.sorting Rugged::SORT_TOPO
    start_refs.each do |ref|
      walker.push ref
    end

    # walker.hide(hex_sha_uninteresting)

    walker.map do |commit|
      [commit.oid, {
        sha1:      commit.oid,
        author:    commit.author,
        message:   commit.message,
        parents:   commit.parents.map { |parent| parent.oid },
        timestamp: commit.time.to_i
      }]
    end.to_h
  end
end