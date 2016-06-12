require 'vimrunner'
require 'vimrunner/rspec'
require_relative './support/vim'

Vimrunner::RSpec.configure do |config|
  config.reuse_server = false

  plugin_path = File.expand_path('.')

  config.start_vim do
    vim = Vimrunner.start_gvim
    vim.add_plugin(plugin_path, 'plugin/archivitor.vim')
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  config.around :each do |example|
    fixtures_path = File.expand_path('../support/fixtures', __FILE__)
    FileUtils.cp_r(fixtures_path, FileUtils.getwd)

    example.run

    if example.exception
      puts "Error encountered, Vim message log:\n#{vim.command(:messages)}"
    end
  end
end
