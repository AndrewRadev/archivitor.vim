require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  plugin_path = File.expand_path('.')

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/edit_archive.vim')
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  config.before :each do
    fixtures_path = File.expand_path('../support/fixtures', __FILE__)
    FileUtils.cp_r(fixtures_path, FileUtils.getwd)
  end
end
