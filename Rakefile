task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/archivitor.zip autoload/ doc/archivitor.txt plugin/ syntax/'
end
