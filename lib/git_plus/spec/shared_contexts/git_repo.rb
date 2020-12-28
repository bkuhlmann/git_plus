# frozen_string_literal: true

RSpec.shared_context "with Git repository" do
  include_context "with temporary directory"

  using Refinements::Pathnames

  let(:git_repo_dir) { temp_dir.join "test" }

  around do |example|
    git_repo_dir.make_dir.change_dir do
      git_repo_dir.join("README.md").touch

      `git init`
      `git config user.name "Test User"`
      `git config user.email "test@example.com"`
      `git config core.hooksPath /dev/null`
      `git config commit.gpgSign false`
      `git config tag.gpgSign false`
      `git config remote.origin.url https://github.com/bkuhlmann/test`
      `git add --all .`
      `git commit --all --message "Added documentation"`
    end

    example.run

    temp_dir.remove_tree
  end
end
