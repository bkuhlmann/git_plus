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

      def get key, *arguments
        call(*arguments, "--get", key).then { |stdout, _stderr, _status| stdout.chomp }
      end

      def remote?
        !get("remote.origin.url").empty?
      end

      def set key, value, *arguments
        call(*arguments, "--add", key, value).then { |_stdout, _stderr, status| status.success? }
      end

      private

      attr_reader :environment, :shell
    end
  end
end