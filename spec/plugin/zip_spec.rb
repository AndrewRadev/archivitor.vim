require 'spec_helper'

describe "Zip files" do
  it "can read zip files' contents" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can update zip files' contents" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `unzip -qql fixtures/test.zip`
    expect(archive_contents).to include 'test2.txt'
  end

  it "can update files within zip files" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.feedkeys 'gf'
    vim.feedkeys 'cwchanged'
    vim.write

    system 'unzip fixtures/test.zip'
    expect(File.read('test.txt').strip).to eq 'changed'
  end

  it "can delete files in zip archives" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.feedkeys 'dd'
    vim.write

    system 'unzip fixtures/test.zip'
    expect(File.exists?('test.txt')).to be_falsey
  end

  it "can create a brand new archive" do
    expect {
      vim.edit 'new_archive.zip'
      vim.feedkeys 'Gotest.txt'
      vim.write
    }.to change{
      File.exists?('new_archive.zip')
    }.from(false).to(true)
  end

  it "can operate on files with spaces" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.normal 'otest with spaces.txt'
    vim.write

    vim.search 'test with spaces'
    vim.feedkeys 'gf'
    vim.feedkeys 'iupdated'
    # force sync
    vim.command(:echo)
    vim.write

    system 'unzip fixtures/test.zip'
    expect(File.read('test with spaces.txt').strip).to eq 'updated'
  end
end
