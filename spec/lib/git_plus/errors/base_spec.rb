# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Errors::Base do
  subject(:base_error) { described_class.new }

  describe "#message" do
    it "answers default message" do
      expect(base_error.message).to eq("Invalid Git+ action.")
    end
  end
end
