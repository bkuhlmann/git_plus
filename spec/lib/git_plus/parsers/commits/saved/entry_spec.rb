# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Parsers::Commits::Saved::Entry do
  using Refinements::Structs

  subject(:parser) { described_class.new }

  let :attributes_without_body do
    {
      author_date_relative: "0 seconds ago",
      author_email: "test@example.com",
      author_name: "Test User",
      body: "",
      message: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      subject: "Added documentation",
      trailers: ""
    }
  end

  let :commit_without_body do
    GitPlus::Commit[
      author_date_relative: "0 seconds ago",
      author_email: "test@example.com",
      author_name: "Test User",
      body: "",
      body_lines: [],
      body_paragraphs: [],
      message: "",
      sha: "180dec7d8ae8cbe3565a727c63c2111e49e0b737",
      subject: "Added documentation",
      trailers: [],
      trailers_index: nil
    ]
  end

  describe ".call" do
    it "answers parsed commit" do
      expect(described_class.call(**attributes_without_body)).to eq(commit_without_body)
    end
  end

  describe "#call" do
    it "answers commit without body" do
      expect(parser.call(**attributes_without_body)).to eq(commit_without_body)
    end

    context "with single line body" do
      let(:attributes) { attributes_without_body.merge body: "Test.\n" }

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["Test."],
                                  body_paragraphs: ["Test."]
      end

      it "answers commit body lines and paragraphs" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with multi-line body" do
      let(:attributes) { attributes_without_body.merge body: "One.\nTwo.\nThree.\n" }

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One.", "Two.", "Three."],
                                  body_paragraphs: ["One.\nTwo.\nThree."]
      end

      it "answers commit body lines and paragraphs" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with comments embedded in paragraphs" do
      let :attributes do
        attributes_without_body.merge body: "One.\n# Test.\nTwo.\n\nThree.\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One.", "Two.", "", "Three."],
                                  body_paragraphs: ["One.\n# Test.\nTwo.", "Three."]
      end

      it "answers commit body lines and paragraphs with comments" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with paragraphs" do
      let :attributes do
        attributes_without_body.merge body: "One.\n\nTwo.\n\nThree.\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One.", "", "Two.", "", "Three."],
                                  body_paragraphs: ["One.", "Two.", "Three."]
      end

      it "answers commit body lines and paragraphs" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with multi-line paragraphs" do
      let :attributes do
        attributes_without_body.merge body: "One A.\nOne B.\n\nTwo A.\nTwo B.\n\nThree.\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: [
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
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with comment paragraphs only" do
      let :attributes do
        attributes_without_body.merge body: "# One.\n\n# Two.\n\n# Three.\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body], body_lines: [], body_paragraphs: []
      end

      it "answers empty commit body lines and paragraphs" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with mixed paragraphs of comments and text" do
      let :attributes do
        attributes_without_body.merge body: "One.\n\n# Two A.\n# Two B.\n\nThree.\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One.", "", "", "Three."],
                                  body_paragraphs: ["One.", "Three."]
      end

      it "answers commit body lines and paragraphs without comments" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with trailers" do
      let :attributes do
        attributes_without_body.merge body: "One.\n\nOne: 1\nTwo: 2\n", trailers: "One: 1\nTwo: 2\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One."],
                                  body_paragraphs: ["One."],
                                  trailers: ["One: 1", "Two: 2"],
                                  trailers_index: 2
      end

      it "answers commit body lines and paragraphs without trailers" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end

    context "with trailers and suffixed comments" do
      let :attributes do
        attributes_without_body.merge body: "One.\n\nOne: 1\n\n# One.\n\n# Two.\n",
                                      trailers: "One: 1\n"
      end

      let :commit do
        commit_without_body.merge body: attributes[:body],
                                  body_lines: ["One."],
                                  body_paragraphs: ["One."],
                                  trailers: ["One: 1"],
                                  trailers_index: 2
      end

      it "answers commit body lines and paragraphs without trailers or comments" do
        expect(parser.call(**attributes)).to eq(commit)
      end
    end
  end
end
