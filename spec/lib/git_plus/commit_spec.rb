# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commit do
  subject(:comment) { described_class.new }

  describe "#initialize" do
    let :attributes do
      {
        author_date_relative: nil,
        author_email: nil,
        author_name: nil,
        body: nil,
        body_lines: nil,
        body_paragraphs: nil,
        message: nil,
        sha: nil,
        subject: nil,
        trailers: nil,
        trailers_index: nil
      }
    end

    it "answers default attributes" do
      expect(comment).to have_attributes(attributes)
    end
  end

  describe "#fixup?" do
    it "answers true when subject includes fixup! prefix" do
      commit = described_class[subject: "fixup! Added test file"]
      expect(commit.fixup?).to eq(true)
    end

    it "answers false when subject excludes fixup! prefix" do
      commit = described_class[subject: "Added test file"]
      expect(commit.fixup?).to eq(false)
    end
  end

  describe "#squash?" do
    it "answers true when subject includes squash! prefix" do
      commit = described_class[subject: "squash! Added test file"]
      expect(commit.squash?).to eq(true)
    end

    it "answers false when subject excludes squash! prefix" do
      commit = described_class[subject: "Added test file"]
      expect(commit.squash?).to eq(false)
    end
  end
end
