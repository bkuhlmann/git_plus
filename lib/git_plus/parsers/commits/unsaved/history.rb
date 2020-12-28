# frozen_string_literal: true

module GitPlus
  module Parsers
    module Commits
      module Unsaved
        # Parses unsaved commit history into commit objects.
        class History
          def initialize entry: Entry
            @entry = entry
          end

          def call path
            fail Errors::Base, %(Invalid commit message path: "#{path}".) unless path.exist?

            path.read.scrub("?").then { |message| entry.call message }
          end

          private

          attr_reader :entry
        end
      end
    end
  end
end
