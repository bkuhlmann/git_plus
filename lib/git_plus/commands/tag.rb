# frozen_string_literal: true

require "open3"
require "tempfile"

module GitPlus
  module Commands
    # A Git tag command wrapper.
    class Tag
      def initialize shell: Open3
        @shell = shell
      end

      def call(*arguments) = shell.capture3("git", "tag", *arguments)

      def exist?(version) = local?(version) || remote?(version)

      def last
        shell.capture3("git", "describe", "--abbrev=0", "--tags", "--always")
             .then { |stdout, _stderr, status| status.success? ? stdout.strip : "" }
      end

      def local? version
        call("--list", version).then do |stdout, _stderr, status|
          status.success? && stdout.match?(/\A#{version}\Z/)
        end
      end

      def push = shell.capture3("git", "push", "--tags")

      def remote? version
        shell.capture3("git", "ls-remote", "--tags", "origin", version)
             .then do |stdout, _stderr, status|
               status.success? && stdout.match?(%r(.+tags/#{version}\Z))
             end
      end

      def sign(version, body = "") = create(version, body, %w[--sign])

      def tagged? = call.then { |stdout, _stderr, status| status.success? && !stdout.empty? }

      def unsign(version, body = "") = create(version, body, %w[--no-sign])

      private

      attr_reader :shell

      def create version, body, options = []
        fail Errors::Base, "Unable to create Git tag without version." unless version
        fail Errors::Base, "Tag exists: #{version}." if exist? version

        Tempfile.open Identity::NAME do |file|
          file.write body
          write version, file.tap(&:rewind), options
        end
      end

      def write version, file, options = []
        arguments = ["--annotate", version, "--cleanup", "verbatim", *options, "--file", file.path]

        call(*arguments).then do |_stdout, _stderr, status|
          fail Errors::Base, "Unable to create tag: #{version}." unless status.success?
        end
      end
    end
  end
end
