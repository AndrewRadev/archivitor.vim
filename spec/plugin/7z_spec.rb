require 'spec_helper'

describe "7z files" do
  it "can read 7z files' contents" do
    vim.edit 'fixtures/test.7z'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end

  it "can update 7z files' contents" do
    vim.edit 'fixtures/test.7z'

    vim.search 'test.txt'
    vim.normal 'otest2.txt'
    vim.write

    archive_contents = `7z l fixtures/test.7z`
    expect(archive_contents).to include 'test2.txt'
  end

  it "can update files within 7z files" do
    vim.edit 'fixtures/test.7z'

    vim.search 'test.txt'
    vim.feedkeys 'gf'
    vim.feedkeys 'cwchanged'
    vim.write

    system '7z x fixtures/test.7z'
    expect(File.read('test.txt').strip).to eq 'changed'
  end

  it "can delete files in 7z archives" do
    vim.edit 'fixtures/test.7z'

    vim.search 'test.txt'
    vim.feedkeys 'dd'
    vim.write

    system '7z x fixtures/test.7z'
    expect(File.exists?('test.txt')).to be_falsey
  end

  it "can create a brand new archive" do
    expect {
      vim.edit 'new_archive.7z'
      vim.feedkeys 'Gotest.txt'
      vim.write
    }.to change{
      File.exists?('new_archive.7z')
    }.from(false).to(true)
  end
end
