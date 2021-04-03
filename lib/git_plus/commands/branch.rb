# frozen_string_literal: true

require "open3"

module GitPlus
  module Commands
    # A Git branch command wrapper.
    class Branch
      def initialize shell: Open3
        @shell = shell
      end

      def default
        shell.capture3("git", "config", "init.defaultBranch").then do |stdout, _stderr, status|
          name = String stdout.chomp
          status.success? && !name.empty? ? name : "master"
        end
      end

      def call(*arguments) = shell.capture3("git", "branch", *arguments)

      def name
        shell.capture3("git", "rev-parse", "--abbrev-ref", "HEAD").then do |stdout, stderr, status|
          status.success? ? stdout.chomp : stderr
        end
      end

      private

      attr_reader :shell
    end
  end
end
