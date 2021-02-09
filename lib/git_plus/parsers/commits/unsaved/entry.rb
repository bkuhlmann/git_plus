# frozen_string_literal: true

require "refinements/structs"
require "securerandom"

module GitPlus
  module Parsers
    module Commits
      module Unsaved
        # Parses an unsaved commit entry into a commit object.
        class Entry
          using ::Refinements::Structs

          SUBJECT_INDEX = 1
          SCISSOR_PATTERN = /\#\s-+\s>8\s-+\n.+/m

          def self.call message
            new.call message
          end

          def initialize sha: SecureRandom.hex(20), commit: Commit.new, repository: Repository.new
            @sha = sha
            @commit = commit.dup
            @repository = repository
          end

          def call message
            # TODO: Ensure message remains blank and mimics saved commit behavior with subject
            # only.
            commit.merge!(author_date_relative: "0 seconds ago", message: message, sha: sha)
                  .tap { build }
          end

          private

          attr_reader :sha, :commit, :repository

          def build = private_methods.grep(/\Astep_/).sort.each { |method| __send__ method }

          def step_a_author_name = commit.author_name = repository.config_get("user.name")

          def step_b_author_email = commit.author_email = repository.config_get("user.email")

          def step_c_subject = commit.subject = commit.message.split("\n").first

          # TODO: Remove leading and trailing empty lines.
          def step_d_body
            commit.message
                  .sub(SCISSOR_PATTERN, "")
                  .split("\n")
                  .drop(SUBJECT_INDEX)
                  .then do |lines|
                    computed_body = lines.join "\n"
                    commit.body = lines.empty? ? computed_body : "#{computed_body}\n"
                  end
          end

          def step_e_trailers
            commit.trailers = repository.trailers_list stdin_data: commit.message
          end

          def step_f_trailers_index
            commit.trailers_index = commit.body.split("\n").index commit.trailers.first
          end

          # TODO: Remove leading and trailing empty lines.
          def step_g_body_lines
            commit.body_lines = body_without_trailers.split("\n")
                                                     .reject { |line| line.start_with? "#" }
                                                     .reverse
                                                     .drop_while(&:empty?).reverse
          end

          # TODO: Remove leading and trailing empty lines.
          def step_h_body_paragraphs
            commit.body_paragraphs = body_without_trailers.split("\n\n")
                                                          .map { |line| line.delete_prefix "\n" }
                                                          .map(&:chomp)
                                                          .reject { |line| line.start_with? "#" }
          end

          def body_without_trailers = commit.body.sub(commit.trailers.join("\n"), "").chomp
        end
      end
    end
  end
end
