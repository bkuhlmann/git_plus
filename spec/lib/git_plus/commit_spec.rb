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

  describe "#amend?" do
    it "answers true when subject includes amend! prefix" do
      expect(described_class[subject: "amend! Added test file"].amend?).to eq(true)
    end

    it "answers false when subject excludes amend! prefix" do
      expect(described_class[subject: "Added test file"].amend?).to eq(false)
    end
  end

  describe "#fixup?" do
    it "answers true when subject includes fixup! prefix" do
      expect(described_class[subject: "fixup! Added test file"].fixup?).to eq(true)
    end

    it "answers false when subject excludes fixup! prefix" do
      expect(described_class[subject: "Added test file"].fixup?).to eq(false)
    end
  end

  describe "#squash?" do
    it "answers true when subject includes squash! prefix" do
      expect(described_class[subject: "squash! Added test file"].squash?).to eq(true)
    end

    it "answers false when subject excludes squash! prefix" do
      expect(described_class[subject: "Added test file"].squash?).to eq(false)
    end
  end

  describe "#prefix?" do
    it "answers true when subject includes amend! prefix" do
      expect(described_class[subject: "amend! Added test file"].prefix?).to eq(true)
    end

    it "answers true when subject includes fixup! prefix" do
      expect(described_class[subject: "fixup! Added test file"].prefix?).to eq(true)
    end

    it "answers true when subject includes squash! prefix" do
      expect(described_class[subject: "squash! Added test file"].prefix?).to eq(true)
    end

    it "answers false when subject's prefix is normal" do
      expect(described_class[subject: "Added test file"].prefix?).to eq(false)
    end
  end
end
