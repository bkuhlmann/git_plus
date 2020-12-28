# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Parsers::Commits::Unsaved::History do
  subject(:parser) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    context "with subject, body, and trailers" do
      let(:path) { Bundler.root.join "spec/support/fixtures/commit-valid.txt" }

      let :proof do
        {
          author_date_relative: "0 seconds ago",
          author_email: "test@example.com",
          author_name: "Test User",
          body: "\nAn example paragraph.\n\nA bullet list:\n  - One.\n\n# A comment block.\n\n" \
                "One: 1\nTwo: 2\n",
          body_lines: [
            "",
            "An example paragraph.",
            "",
            "A bullet list:",
            "  - One."
          ],
          body_paragraphs: [
            "An example paragraph.",
            "A bullet list:\n  - One."
          ],
          message: "Added example\n\nAn example paragraph.\n\nA bullet list:\n  - One.\n\n" \
                   "# A comment block.\n\nOne: 1\nTwo: 2\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added example",
          trailers: [
            "One: 1",
            "Two: 2"
          ],
          trailers_index: 8
        }
      end

      it "answers commit" do
        git_repo_dir.change_dir do
          expect(parser.call(path).to_h).to match(proof)
        end
      end
    end

    context "with subject, body, and verbose details" do
      let(:path) { Bundler.root.join "spec/support/fixtures/commit-scissors.txt" }

      let :proof do
        {
          author_date_relative: "0 seconds ago",
          author_email: "test@example.com",
          author_name: "Test User",
          body: "\nA fixture for commits made via `git commit --verbose` which include\n" \
                "scissor-related content.\n\n# A test comment.\n",
          body_lines: [
            "",
            "A fixture for commits made via `git commit --verbose` which include",
            "scissor-related content."
          ],
          body_paragraphs: [
            "A fixture for commits made via `git commit --verbose` which include\n" \
            "scissor-related content."
          ],
          message: "Added commit with verbose option\n\nA fixture for commits made via " \
                   "`git commit --verbose` which include\nscissor-related content.\n\n# A test " \
                   "comment.\n\n# ------------------------ >8 ------------------------\n# Do not " \
                   "modify or remove the line above.\n# Everything below it will be ignored.\n" \
                   "diff --git c/one.txt i/one.txt\nnew file mode 100644\nindex "\
                   "000000000000..98038f7b36d7\n--- /dev/null\n+++ i/one.txt\n@@ -0,0 +1,5 " \
                   "@@\n+A ruby example:\n+\n+def example\n+  puts \"example\"\n+end\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added commit with verbose option",
          trailers: [],
          trailers_index: nil
        }
      end

      it "answers commit" do
        git_repo_dir.change_dir do
          expect(parser.call(path).to_h).to match(proof)
        end
      end
    end

    context "with combined subject and body" do
      let(:path) { Bundler.root.join "spec/support/fixtures/commit-invalid.txt" }

      let :proof do
        {
          author_date_relative: "0 seconds ago",
          author_email: "test@example.com",
          author_name: "Test User",
          body: "feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu_libero sit amet " \
                "quam egestas semper.\nAenean.\n",
          body_lines: [
            "feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu_libero sit amet quam " \
            "egestas semper.",
            "Aenean."
          ],
          body_paragraphs: [
            "feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu_libero sit amet quam " \
            "egestas semper.\nAenean."
          ],
          message: "Pellentque morbi-trist sentus et netus et malesuada fames ac turpis egestas. " \
                   "Vestibulum tortor quam,\nfeugiat vitae, ultricies eget, tempor sit amet, " \
                   "ante. Donec eu_libero sit amet quam egestas semper.\nAenean.\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Pellentque morbi-trist sentus et netus et malesuada fames ac turpis egestas. " \
                   "Vestibulum tortor quam,",
          trailers: [],
          trailers_index: nil
        }
      end

      it "answers commit" do
        git_repo_dir.change_dir do
          expect(parser.call(path).to_h).to match(proof)
        end
      end
    end

    context "with invalid encoding" do
      let(:path) { temp_dir.join "invalid.txt" }

      let :proof do
        {
          author_date_relative: "0 seconds ago",
          author_email: "test@example.com",
          author_name: "Test User",
          body: "",
          body_lines: [],
          body_paragraphs: [],
          message: "Added ???????",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added ???????",
          trailers: [],
          trailers_index: nil
        }
      end

      it "answers commits with invalid text replaced with question marks" do
        git_repo_dir.change_dir do
          path.write "Added \210\221\332\332\337\341\341"
          expect(parser.call(path).to_h).to match(proof)
        end
      end
    end
  end
end
