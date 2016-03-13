require 'spec_helper'

describe "Zip files" do
  it "can read zip files' contents" do
    vim.edit 'fixtures/test.zip'

    vim.search 'test.txt'
    vim.feedkeys 'gf'

    expect(buffer_contents).to eq 'test'
  end
end
