# frozen_string_literal: true

require "open3"

module GitPlus
  module Commands
    # A Git rev-parse command wrapper.
    class RevParse
      def initialize shell: Open3
        @shell = shell
      end

      def call *arguments
        shell.capture3("git", "rev-parse", *arguments)
      end

      def directory?
        call("--git-dir").then do |stdout, _stderr, status|
          status.success? && stdout.chomp == ".git"
        end
      end

      private

      attr_reader :shell
    end
  end
end
