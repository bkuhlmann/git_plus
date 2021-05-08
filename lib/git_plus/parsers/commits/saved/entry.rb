# frozen_string_literal: true

require "refinements/structs"

module GitPlus
  module Parsers
    module Commits
      module Saved
        # Parses a saved commit entry into a commit object.
        class Entry
          using ::Refinements::Structs

          def self.call **attributes
            new.call(**attributes)
          end

          def initialize commit = Commit.new
            @commit = commit.dup
          end

          def call(**attributes) = commit.merge!(**attributes).tap { build }

          private

          attr_reader :commit

          def build = private_methods.grep(/\Astep_/).sort.each { |method| __send__ method }

          def step_a_trailers = commit.trailers = commit.trailers.split("\n")

          def step_b_trailers_index
            commit.trailers_index = commit.body.split("\n").index commit.trailers.first
          end

          def step_c_body_lines = commit.body_lines = body_without_trailing_spaces

          def step_d_body_paragraphs
            commit.body_paragraphs = body_without_trailers.split("\n\n")
                                                          .map(&:chomp)
                                                          .reject { |line| line.start_with? "#" }
          end

          def body_without_trailing_spaces
            body_without_comments.reverse.drop_while(&:empty?).reverse
          end

          def body_without_comments
            body_without_trailers.split("\n").reject { |line| line.start_with? "#" }
          end

          def body_without_trailers
            body = commit.body
            trailers = commit.trailers

            return body if trailers.empty?

            body.sub(/#{trailers.join "\n"}.*/m, "")
          end
        end
      end
    end
  end
end
