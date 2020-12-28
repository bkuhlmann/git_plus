# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Parsers::Commits::Unsaved::Entry do
  subject(:parser) { described_class.new sha: commit_without_body.sha }

  include_context "with Git repository"

  using Refinements::Pathnames
  using Refinements::Structs

  let :commit_without_body do
    GitPlus::Commit[
      author_date_relative: "0 seconds ago",
      author_email: "test@example.com",
      author_name: "Test User",
      body: "",
      body_lines: [],
      body_paragraphs: [],
      message: "Added documentation",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      subject: "Added documentation",
      trailers: [],
      trailers_index: nil
    ]
  end

  describe ".call" do
    it "answers parsed commit" do
      git_repo_dir.change_dir do
        commit = described_class.call("Added documentation").to_h
        proof = commit_without_body.to_h.merge sha: /\A[0-9a-f]{40}\Z/

        expect(commit).to match(proof)
      end
    end
  end

  describe "#call" do
    it "answers commit without body" do
      git_repo_dir.change_dir do
        expect(parser.call("Added documentation")).to eq(commit_without_body)
      end
    end

    it "answers commit with subject and trailing new lines only" do
      git_repo_dir.change_dir do
        commit = commit_without_body.merge message: "#{commit_without_body.message}\n\n"
        expect(parser.call("Added documentation\n\n")).to eq(commit)
      end
    end

    context "with single line body" do
      let(:message) { "Added documentation\n\nTest.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nTest.\n",
                                  body_lines: ["", "Test."],
                                  body_paragraphs: ["Test."]
      end

      it "answers commit body lines and paragraphs" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with multi-line body" do
      let(:message) { "Added documentation\n\nOne.\nTwo.\nThree.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\nTwo.\nThree.\n",
                                  body_lines: ["", "One.", "Two.", "Three."],
                                  body_paragraphs: ["One.\nTwo.\nThree."]
      end

      it "answers commit body lines and paragraphs" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with comments embedded in paragraphs" do
      let(:message) { "Added documentation\n\nOne.\n# Test.\nTwo.\n\nThree.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\n# Test.\nTwo.\n\nThree.\n",
                                  body_lines: ["", "One.", "Two.", "", "Three."],
                                  body_paragraphs: ["One.\n# Test.\nTwo.", "Three."]
      end

      it "answers commit body lines and paragraphs with comments" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with paragraphs" do
      let(:message) { "Added documentation\n\nOne.\n\nTwo.\n\nThree.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\n\nTwo.\n\nThree.\n",
                                  body_lines: ["", "One.", "", "Two.", "", "Three."],
                                  body_paragraphs: ["One.", "Two.", "Three."]
      end

      it "answers commit body lines and paragraphs with comments" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with multi-line paragraphs" do
      let(:message) { "Added documentation\n\nOne A.\nOne B.\n\nTwo A.\nTwo B.\n\nThree.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne A.\nOne B.\n\nTwo A.\nTwo B.\n\nThree.\n",
                                  body_lines: [
                                    "",
                                    "One A.",
                                    "One B.",
                                    "",
                                    "Two A.",
                                    "Two B.",
                                    "",
                                    "Three."
                                  ],
                                  body_paragraphs: ["One A.\nOne B.", "Two A.\nTwo B.", "Three."]
      end

      it "answers commit body lines and paragraphs" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with comment paragraphs only" do
      let(:message) { "Added documentation\n\n# One.\n\n# Two.\n\n# Three.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\n# One.\n\n# Two.\n\n# Three.\n",
                                  body_lines: [],
                                  body_paragraphs: []
      end

      it "answers empty commit body lines and paragraphs" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with mixed paragraphs of comments and text" do
      let(:message) { "Added documentation\n\nOne.\n\n# Two A.\n# Two B.\n\nThree.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\n\n# Two A.\n# Two B.\n\nThree.\n",
                                  body_lines: ["", "One.", "", "", "Three."],
                                  body_paragraphs: ["One.", "Three."]
      end

      it "answers commit body lines and paragraphs without comments" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with trailers" do
      let(:message) { "Added documentation\n\nOne.\n\nOne: 1\nTwo: 2\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\n\nOne: 1\nTwo: 2\n",
                                  body_lines: ["", "One."],
                                  body_paragraphs: ["One."],
                                  trailers: ["One: 1", "Two: 2"],
                                  trailers_index: 3
      end

      it "answers commit body lines and paragraphs without trailers" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end

    context "with trailers and suffixed comments" do
      let(:message) { "Added documentation\n\nOne.\n\nOne: 1\n\n# One.\n\n# Two.\n" }

      let :commit do
        commit_without_body.merge message: message,
                                  body: "\nOne.\n\nOne: 1\n\n# One.\n\n# Two.\n",
                                  body_lines: ["", "One."],
                                  body_paragraphs: ["One.", ""],
                                  trailers: ["One: 1"],
                                  trailers_index: 3
      end

      it "answers commit body lines and paragraphs without trailers or comments" do
        git_repo_dir.change_dir { expect(parser.call(message)).to eq(commit) }
      end
    end
  end
end
