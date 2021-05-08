# frozen_string_literal: true

require "spec_helper"

RSpec.describe GitPlus::Commands::Tag do
  subject(:tag) { described_class.new }

  include_context "with Git repository"

  using Refinements::Pathnames

  shared_examples_for "a tag" do |method|
    it "fails when there is no version" do
      expectation = proc { tag.public_send method, nil }

      expect(&expectation).to raise_error(
        GitPlus::Errors::Base,
        "Unable to create Git tag without version."
      )
    end

    it "prints warning when tag exists" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        expectation = proc { tag.public_send method, "0.1.0" }

        expect(&expectation).to raise_error(GitPlus::Errors::Base, "Tag exists: 0.1.0.")
      end
    end
  end

  describe "#call" do
    it "answers standard output, standard error, and status" do
      git_repo_dir.change_dir do
        expect(tag.call("--list")).to match(
          array_including("", "", kind_of(Process::Status))
        )
      end
    end
  end

  describe "#exist?" do
    it "answers true when only local tag exists" do
      git_repo_dir.change_dir do
        `git tag 0.0.0`
        expect(tag.exist?("0.0.0")).to eq(true)
      end
    end

    it "answers true when only remote tag exists" do
      git_repo_dir.change_dir { expect(tag.exist?("0.1.0")).to eq(true) }
    end

    it "answers false when local and remote tags don't exist" do
      git_repo_dir.change_dir { expect(tag.exist?("0.0.0")).to eq(false) }
    end
  end

  describe "#last" do
    it "answers SHA of first commit when no tags exist" do
      git_repo_dir.change_dir { expect(tag.last).to match(/[0-9a-f]{40}/) }
    end

    it "answers last tag when tag exists" do
      git_repo_dir.change_dir do
        `touch test.txt && git add . && git commit --message "Added test file" && git tag 0.1.0`
        expect(tag.last).to eq("0.1.0")
      end
    end
  end

  describe "#local?" do
    it "answers true with matching tag" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        expect(tag.local?("0.1.0")).to eq(true)
      end
    end

    it "answers false with non-existant tag" do
      git_repo_dir.change_dir do
        `git tag 0.0.0`
        expect(tag.local?("0.1.0")).to eq(false)
      end
    end

    it "answers false with no tags" do
      git_repo_dir.change_dir { expect(tag.local?("0.1.0")).to eq(false) }
    end
  end

  describe "#push" do
    subject(:tag) { described_class.new shell: shell }

    let(:shell) { class_spy Open3 }

    it "pushes tags" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        tag.push

        expect(shell).to have_received(:capture3).with("git", "push", "--tags")
      end
    end
  end

  describe "#remote?" do
    subject(:tag) { described_class.new shell: shell }

    let(:shell) { class_spy Open3, capture3: ["refs/tags/0.1.0", "", status] }
    let(:status) { instance_spy Process::Status, success?: true }

    it "answers true when tag exists" do
      git_repo_dir.change_dir { expect(tag.remote?("0.1.0")).to eq(true) }
    end

    it "answers false when tag doesn't exist" do
      git_repo_dir.change_dir { expect(tag.remote?("0.2.0")).to eq(false) }
    end
  end

  describe "#sign" do
    it_behaves_like "a tag", :sign

    it "creates signed tag" do
      skip "Temporarily disabled on CI" if ENV["CI"] == "true"

      git_repo_dir.change_dir do
        tag.sign "0.0.0"
        expect(`git show --stat --pretty=format:"%b" "0.0.0"`).to match(/tag 0.0.0.+SIGNATURE/m)
      end
    end
  end

  describe "#tagged?" do
    it "answers true when tags exist" do
      git_repo_dir.change_dir do
        `git tag 0.1.0`
        expect(tag.tagged?).to eq(true)
      end
    end

    it "answers false when tags don't exist" do
      git_repo_dir.change_dir { expect(tag.tagged?).to eq(false) }
    end
  end

  describe "#unsign" do
    it_behaves_like "a tag", :unsign

    it "creates unsigned tag" do
      git_repo_dir.change_dir do
        tag.unsign "0.0.0"
        expect(`git show --stat --pretty=format:"%b" "0.0.0"`).to match(/tag 0.0.0/m)
      end
    end
  end
end
