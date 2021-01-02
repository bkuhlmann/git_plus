# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Config do
  subject(:config) { described_class.new environment: environment }

  include_context "with Git repository"

  using Refinements::Pathnames

  let(:environment) { ENV }

  describe "#call" do
    context "with valid arguments" do
      let(:arguments) { "--list" }

      it "answers results to standard output" do
        git_repo_dir.change_dir do
          stdout, _stderr, _status = config.call arguments
          expect(stdout).to match(%r(core.hookspath=/dev/null)m)
        end
      end

      it "answers empty error output" do
        git_repo_dir.change_dir do
          _stdout, stderr, _status = config.call arguments
          expect(stderr).to eq("")
        end
      end

      it "answers success status" do
        git_repo_dir.change_dir do
          _stdout, _stderr, status = config.call arguments
          expect(status.success?).to eq(true)
        end
      end
    end

    context "with invalid arguments" do
      let(:arguments) { "--bogus" }

      it "answers empty standard output" do
        git_repo_dir.change_dir do
          stdout, _stderr, _status = config.call arguments
          expect(stdout).to eq("")
        end
      end

      it "answers error message" do
        git_repo_dir.change_dir do
          _stdout, stderr, _status = config.call arguments
          expect(stderr).to match(/unknown option.+bogus.+/)
        end
      end

      it "answers false status" do
        git_repo_dir.change_dir do
          _stdout, _stderr, status = config.call arguments
          expect(status.success?).to eq(false)
        end
      end
    end
  end

  describe "#get" do
    let(:key) { "user.name" }

    it "answers value without whitespace when key exists" do
      git_repo_dir.change_dir do
        expect(config.get(key)).to eq("Test User")
      end
    end

    it "answers empty string when key doesn't exist" do
      config = described_class.new environment: {"HOME" => git_repo_dir.to_s}
      expect(config.get(key)).to eq("")
    end

    it "answers empty string when key is invalid" do
      expect(config.get("bogus")).to eq("")
    end

    it "answers default value when key is invalid" do
      expect(config.get("bogus", "fallback")).to eq("fallback")
    end

    it "yields to block when when key is invalid" do
      value = config.get("bogus") { "test" }
      expect(value).to eq("test")
    end

    it "yields standard output when when key is invalid" do
      value = config.get("bogus") { |stdout| stdout }
      expect(value).to eq("")
    end

    it "yields standard output and error when when key is invalid" do
      value = config.get("bogus") { |stdout, stderr| stdout + stderr }
      expect(value).to eq("error: key does not contain a section: bogus\n")
    end
  end

  describe "#remote?" do
    before { temp_dir.change_dir { `git init` } }

    it "answers true when remote repository is defined" do
      temp_dir.change_dir do
        `git config remote.origin.url git@github.com:test/example.git`
        expect(config.remote?).to eq(true)
      end
    end

    it "answers false when remote repository is not defined" do
      temp_dir.change_dir { expect(config.remote?).to eq(false) }
    end
  end

  describe "#set" do
    context "when key exists" do
      let(:key) { "user.name" }
      let(:value) { "Jayne Doe" }

      it "sets key with value" do
        git_repo_dir.change_dir do
          config.set key, value
          expect(config.get(key)).to eq(value)
        end
      end

      it "answers value when key is successfully set" do
        git_repo_dir.change_dir do
          expect(config.set(key, value)).to eq(value)
        end
      end
    end

    context "when key doesn't exist" do
      let(:key) { "user.test" }
      let(:value) { "example" }

      it "sets key with value" do
        git_repo_dir.change_dir do
          config.set key, value
          expect(config.get(key)).to eq(value)
        end
      end

      it "answers value when key is successfully set" do
        git_repo_dir.change_dir do
          expect(config.set(key, value)).to eq("example")
        end
      end
    end

    it "answers error when key is invalid" do
      git_repo_dir.change_dir do
        expect(config.set("bogus", "invalid")).to match(/error/)
      end
    end
  end
end
