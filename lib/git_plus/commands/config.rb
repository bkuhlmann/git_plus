# frozen_string_literal: true

require "open3"

module GitPlus
  module Commands
    # A Git config command wrapper.
    class Config
      def initialize environment: ENV, shell: Open3
        @environment = environment
        @shell = shell
      end

      def call *arguments
        shell.capture3 environment, "git", "config", *arguments
      end

      def get key, value = nil, *arguments
        call(*arguments, "--get", key).then do |stdout, stderr, status|
          if status.success?
            stdout.chomp
          elsif value
            value
          else
            block_given? ? yield(stdout, stderr) : ""
          end
        end
      end

      def origin?
        !get("remote.origin.url").empty?
      end

      def set key, value, *arguments
        call(*arguments, "--add", key, value).then do |_stdout, stderr, status|
          status.success? ? value : stderr
        end
      end

      private

      attr_reader :environment, :shell
    end
  end
end
