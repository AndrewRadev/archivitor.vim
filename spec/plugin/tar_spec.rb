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

  it "can update tar.gz files' contents" do
    vim.edit 'fixtures/test.tar.gz'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `tar -tf fixtures/test.tar.gz`
    expect(archive_contents).to include 'test2.txt'
  end

  it "can update tar.bz2 files' contents" do
    vim.edit 'fixtures/test.tar.bz2'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `tar -tf fixtures/test.tar.bz2`
    expect(archive_contents).to include 'test2.txt'
  end

  it "can update tar.xz files' contents" do
    vim.edit 'fixtures/test.tar.xz'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `tar -tf fixtures/test.tar.xz`
    expect(archive_contents).to include 'test2.txt'
  end

  it "can update files within tar files" do
    vim.edit 'fixtures/test.tar'

    vim.search 'test.txt'
    vim.feedkeys 'gf'
    vim.feedkeys 'cwchanged'
    vim.write

    system 'tar xf fixtures/test.tar'
    expect(File.read('test.txt').strip).to eq 'changed'
  end

  it "can update files within compressed tar files" do
    vim.edit 'fixtures/test.tar.gz'

    vim.search 'test.txt'
    vim.feedkeys 'gf'
    vim.feedkeys 'cwchanged'
    vim.write

    system 'tar xzf fixtures/test.tar.gz'
    expect(File.read('test.txt').strip).to eq 'changed'
  end

  it "can delete files in tar archives" do
    vim.edit 'fixtures/test.tar'

    vim.search 'test.txt'
    vim.feedkeys 'dd'
    vim.write

    system 'tar xf fixtures/test.tar'
    expect(File.exists?('test.txt')).to be_falsey
  end

  it "can delete files in compressed tar archives" do
    vim.edit 'fixtures/test.tar.gz'

    vim.search 'test.txt'
    vim.feedkeys 'dd'
    vim.write

    system 'tar xzf fixtures/test.tar.gz'
    expect(File.exists?('test.txt')).to be_falsey
  end
end
