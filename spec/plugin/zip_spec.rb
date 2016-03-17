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
end
