# frozen_string_literal: true

require "forwardable"

module GitPlus
  # Primary object/wrapper for processing all Git related commands.
  class Repository
    extend Forwardable

    COMMANDS = {
      proxy_branch: Commands::Branch.new,
      proxy_commits: Parsers::Commits::Saved::History.new,
      proxy_config: Commands::Config.new,
      proxy_log: Commands::Log.new,
      proxy_rev_parse: Commands::RevParse.new,
      proxy_tag: Commands::Tag.new,
      proxy_trailers: Commands::Trailers.new,
      proxy_unsaved: Parsers::Commits::Unsaved::History.new
    }.freeze

    def_instance_delegator :proxy_branch, :call, :branch
    def_instance_delegator :proxy_branch, :name, :branch_name
    def_instance_delegator :proxy_commits, :call, :commits
    def_instance_delegator :proxy_config, :call, :config
    def_instance_delegator :proxy_config, :get, :config_get
    def_instance_delegator :proxy_config, :remote?, :config_remote?
    def_instance_delegator :proxy_config, :set, :config_set
    def_instance_delegator :proxy_log, :call, :log
    def_instance_delegator :proxy_rev_parse, :call, :rev_parse
    def_instance_delegator :proxy_rev_parse, :directory?, :exist?
    def_instance_delegator :proxy_tag, :call, :tag
    def_instance_delegator :proxy_tag, :exist?, :tag_exist?
    def_instance_delegator :proxy_tag, :last, :tag_last
    def_instance_delegator :proxy_tag, :local?, :tag_local?
    def_instance_delegator :proxy_tag, :push, :tag_push
    def_instance_delegator :proxy_tag, :remote?, :tag_remote?
    def_instance_delegator :proxy_tag, :sign, :tag_sign
    def_instance_delegator :proxy_tag, :tagged?
    def_instance_delegator :proxy_tag, :unsign, :tag_unsign
    def_instance_delegator :proxy_trailers, :call, :trailers
    def_instance_delegator :proxy_trailers, :list, :trailers_list
    def_instance_delegator :proxy_unsaved, :call, :unsaved

    def initialize commands: COMMANDS
      @commands = commands
    end

    private

    attr_reader :commands

    # TODO: Remove and delegate to all of these private methods too.
    # FIX: Errros with forwarding to private method RSpec::Mocks::InstanceVerifyingDouble spec.

    def proxy_branch
      commands.fetch __method__
    end

    def proxy_commits
      commands.fetch __method__
    end

    def proxy_config
      commands.fetch __method__
    end

    def proxy_log
      commands.fetch __method__
    end

    def proxy_rev_parse
      commands.fetch __method__
    end

    def proxy_tag
      commands.fetch __method__
    end

    def proxy_trailers
      commands.fetch __method__
    end

    def proxy_unsaved
      commands.fetch __method__
    end
  end
end
