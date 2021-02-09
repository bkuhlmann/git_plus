# frozen_string_literal: true

require "open3"

module GitPlus
  module Commands
    # A Git interpret-trailers command wrapper.
    class Trailers
      def initialize shell: Open3
        @shell = shell
      end

      def call(*arguments) = shell.capture3("git", "interpret-trailers", *arguments)

      def list *arguments
        call(*arguments.prepend("--only-trailers")).then do |stdout, _stderr, status|
          status.success? ? stdout.split("\n") : []
        end
      end

      private

      attr_reader :shell
    end
  end
end
