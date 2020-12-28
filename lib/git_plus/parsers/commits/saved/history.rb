# frozen_string_literal: true

require "refinements/arrays"
require "refinements/structs"

module GitPlus
  module Parsers
    module Commits
      module Saved
        # Parses saved commit history into commit objects.
        class History
          using ::Refinements::Arrays
          using ::Refinements::Structs

          PATTERN = {
            sha: "%H",
            author_name: "%an",
            author_email: "%ae",
            author_date_relative: "%ar",
            subject: "%s",
            body: "%b",
            message: "%B",
            trailers: "%(trailers)"
          }.freeze

          def initialize pattern: PATTERN, entry: Entry, log: Commands::Log.new
            @pattern = pattern
            @entry = entry
            @log = log
          end

          def call *arguments
            arguments.including(format)
                     .then { |pretty_format| process(*pretty_format) }
                     .map { |response| parse response }
                     .map { |attributes| entry.call(**attributes) }
          end

          private

          attr_reader :pattern, :entry, :log

          def format
            pattern.reduce("") { |string, (key, value)| string + "<#{key}>#{value}</#{key}>%n" }
                   .then { |structure| %(--pretty=format:"#{structure}") }
          end

          def process *arguments
            log.call(*arguments).then do |stdout, _stderr, status|
              status.success? ? stdout.scrub("?").split(%(\"\n\")) : []
            end
          end

          def parse response
            pattern.keys.reduce({}) do |body, key|
              body.merge key => String(response[%r(<#{key}>(?<content>.*?)</#{key}>)m, :content])
            end
          end
        end
      end
    end
  end
end
