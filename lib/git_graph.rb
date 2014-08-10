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

  def branches
    @repository.branches.each_name().to_a +
    @repository.tags.each_name().to_a -
    ['origin/HEAD']
  end

  def resolve_commits(references)
    references.map do |reference|
      head = false

      if reference == 'HEAD'
        reference = @repository.head.target_id
        head = true
      end

      if @repository.branches[reference]
        object = @repository.lookup @repository.branches[reference].target_id
      elsif @repository.tags[reference]
        object = @repository.lookup @repository.tags[reference].target_id
      else
        object = @repository.lookup reference
      end

      case object.type
      when :commit
        commit = object
      when :tag
        commit = Rugged::Commit.lookup @repository, target
      end

      if head
        next ['HEAD', {type: :head, target: commit.oid}]
      end

      if @repository.branches[reference]
        [reference, {type: :branch, target: commit.oid}]
      elsif @repository.tags[reference]
        [reference, {type: :tag,    target: commit.oid}]
      else
        raise 'Unknown reference object'
        p object
      end
    end.to_h
  end
end
