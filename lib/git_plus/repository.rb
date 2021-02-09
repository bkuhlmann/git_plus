# frozen_string_literal: true

require "forwardable"

module GitPlus
  # Primary object/wrapper for processing all Git related commands.
  class Repository
    extend Forwardable

    DELEGATES = {
      delegate_branch: Commands::Branch.new,
      delegate_commits: Parsers::Commits::Saved::History.new,
      delegate_config: Commands::Config.new,
      delegate_log: Commands::Log.new,
      delegate_rev_parse: Commands::RevParse.new,
      delegate_tag: Commands::Tag.new,
      delegate_trailers: Commands::Trailers.new,
      delegate_unsaved: Parsers::Commits::Unsaved::History.new
    }.freeze

    def_instance_delegator :delegate_branch, :call, :branch
    def_instance_delegator :delegate_branch, :name, :branch_name
    def_instance_delegator :delegate_commits, :call, :commits
    def_instance_delegator :delegate_config, :call, :config
    def_instance_delegator :delegate_config, :get, :config_get
    def_instance_delegator :delegate_config, :origin?, :config_origin?
    def_instance_delegator :delegate_config, :set, :config_set
    def_instance_delegator :delegate_log, :call, :log
    def_instance_delegator :delegate_rev_parse, :call, :rev_parse
    def_instance_delegator :delegate_rev_parse, :directory?, :exist?
    def_instance_delegator :delegate_tag, :call, :tag
    def_instance_delegator :delegate_tag, :exist?, :tag_exist?
    def_instance_delegator :delegate_tag, :last, :tag_last
    def_instance_delegator :delegate_tag, :local?, :tag_local?
    def_instance_delegator :delegate_tag, :push, :tag_push
    def_instance_delegator :delegate_tag, :remote?, :tag_remote?
    def_instance_delegator :delegate_tag, :sign, :tag_sign
    def_instance_delegator :delegate_tag, :tagged?
    def_instance_delegator :delegate_tag, :unsign, :tag_unsign
    def_instance_delegator :delegate_trailers, :call, :trailers
    def_instance_delegator :delegate_trailers, :list, :trailers_list
    def_instance_delegator :delegate_unsaved, :call, :unsaved

    def initialize delegates: DELEGATES
      @delegates = delegates
    end

    private

    attr_reader :delegates

    def delegate_branch = delegates.fetch(__method__)

    def delegate_commits = delegates.fetch(__method__)

    def delegate_config = delegates.fetch(__method__)

    def delegate_log = delegates.fetch(__method__)

    def delegate_rev_parse = delegates.fetch(__method__)

    def delegate_tag = delegates.fetch(__method__)

    def delegate_trailers = delegates.fetch(__method__)

    def delegate_unsaved = delegates.fetch(__method__)
  end
end
