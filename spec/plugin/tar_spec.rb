require 'spec_helper'

describe "Tar files" do
  it "can read tar files' contents" do
    vim.edit 'fixtures/test.tar'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can read tar.gz files' contents" do
    vim.edit 'fixtures/test.tar.gz'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can read tar.bz2 files' contents" do
    vim.edit 'fixtures/test.tar.bz2'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can read tar.xz files' contents" do
    vim.edit 'fixtures/test.tar.xz'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can update tar files' contents" do
    vim.edit 'fixtures/test.tar'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `tar -tf fixtures/test.tar`
    expect(archive_contents).to include 'test2.txt'
  end
end
