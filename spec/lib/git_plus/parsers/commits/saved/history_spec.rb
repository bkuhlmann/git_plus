# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Parsers::Commits::Saved::History do
  subject(:parser) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  describe "#call" do
    let :default_proof do
      hash_including(
        author_date_relative: /\A\d+ seconds?? ago\Z/,
        author_email: "test@example.com",
        author_name: "Test User",
        body: "",
        body_lines: [],
        body_paragraphs: [],
        message: "Added documentation\n",
        sha: /\A[0-9a-f]{40}\Z/,
        subject: "Added documentation",
        trailers: [],
        trailers_index: nil
      )
    end

    it "answers commits with range only" do
      git_repo_dir.change_dir do
        commits = parser.call("-1").map(&:to_h)
        expect(commits).to contain_exactly(default_proof)
      end
    end

    it "answers commits with flags only" do
      git_repo_dir.change_dir do
        commits = parser.call("--author", "Test User").map(&:to_h)
        expect(commits).to contain_exactly(default_proof)
      end
    end

    it "answers commits with range and flags" do
      git_repo_dir.change_dir do
        commits = parser.call("--author", "Test User", "-1").map(&:to_h)
        expect(commits).to contain_exactly(default_proof)
      end
    end

    it "answers commits with subject only" do
      git_repo_dir.change_dir do
        commits = parser.call.map(&:to_h)
        expect(commits).to contain_exactly(default_proof)
      end
    end

    context "with subject and single-line body" do
      let :commit do
        "Added test\n\n" \
        "One.\n"
      end

      let :proof do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "One.\n",
          body_lines: ["One."],
          body_paragraphs: ["One."],
          message: "Added test\n\nOne.\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added test",
          trailers: [],
          trailers_index: nil
        )
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          `git commit --amend --message '#{commit}'`
          commits = parser.call.map(&:to_h)

          expect(commits).to contain_exactly(proof)
        end
      end
    end

    context "with subject, body, and trailers" do
      let :commit do
        "Added test\n\n" \
        "One.\n\n" \
        "One: 1\n" \
        "Two: 2\n"
      end

      let :proof do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "One.\n\nOne: 1\nTwo: 2\n",
          body_lines: ["One."],
          body_paragraphs: ["One."],
          message: "Added test\n\nOne.\n\nOne: 1\nTwo: 2\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added test",
          trailers: ["One: 1", "Two: 2"],
          trailers_index: 2
        )
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          `git commit --amend --message '#{commit}'`
          commits = parser.call.map(&:to_h)

          expect(commits).to contain_exactly(proof)
        end
      end
    end

    context "with subject, body, trailers, and intermixed comments" do
      let :commit do
        "Added test\n\n" \
        "# One\n\n" \
        "One.\n\n" \
        "# Two.\n\n" \
        "One: 1\n\n" \
        "# Three.\n"
      end

      let :proof do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "# One\n\nOne.\n\n# Two.\n\nOne: 1\n\n# Three.\n",
          body_lines: ["", "One."],
          body_paragraphs: ["One."],
          message: "Added test\n\n# One\n\nOne.\n\n# Two.\n\nOne: 1\n\n# Three.\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added test",
          trailers: ["One: 1"],
          trailers_index: 6
        )
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          `git commit --amend --message '#{commit}'`
          commits = parser.call.map(&:to_h)

          expect(commits).to contain_exactly(proof)
        end
      end
    end

    context "with invalid encoding" do
      let :proof do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "",
          body_lines: [],
          body_paragraphs: [],
          message: "Added ???????\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added ???????",
          trailers: [],
          trailers_index: nil
        )
      end

      it "answers commits with invalid text replaced with question marks" do
        git_repo_dir.change_dir do
          `git config i18n.commitEncoding Shift_JIS`
          `git commit --amend --message "Added \210\221\332\332\337\341\341"`
          commits = parser.call.map(&:to_h)

          expect(commits).to contain_exactly(proof)
        end
      end
    end

    context "with multiple commits" do
      let :proof_one do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "",
          body_lines: [],
          body_paragraphs: [],
          message: "Added documentation\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added documentation",
          trailers: [],
          trailers_index: nil
        )
      end

      let :proof_two do
        hash_including(
          author_date_relative: /\A\d+ seconds?? ago\Z/,
          author_email: "test@example.com",
          author_name: "Test User",
          body: "",
          body_lines: [],
          body_paragraphs: [],
          message: "Added documentation\n",
          sha: /\A[0-9a-f]{40}\Z/,
          subject: "Added documentation",
          trailers: [],
          trailers_index: nil
        )
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          `touch test.txt && git add --all && git commit --message "Added documentation"`
          commits = parser.call.map(&:to_h)

          expect(commits).to contain_exactly(proof_one, proof_two)
        end
      end
    end
  end
end
