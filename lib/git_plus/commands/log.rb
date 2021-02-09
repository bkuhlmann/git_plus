# frozen_string_literal: true

require "open3"

module GitPlus
  module Commands
    # A Git log command wrapper.
    class Log
      def initialize shell: Open3
        @shell = shell
      end

      def call(*arguments) = shell.capture3("git", "log", *arguments)

      private

      attr_reader :shell
    end
  end
end
