let s:cached_tempfiles = {}

function! archivitor#tar#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('archivitor#tar#Filelist'),
        \ 'Extract':  function('archivitor#tar#Extract'),
        \ 'Update':   function('archivitor#tar#Update'),
        \ 'Add':      function('archivitor#tar#Add'),
        \ 'Delete':   function('archivitor#tar#Delete'),
        \ }
endfunction

function! archivitor#tar#Filelist() dict
  let file_list = []
  for line in split(archivitor#System('tar -tf', self.name), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return sort(file_list)
endfunction

function! archivitor#tar#Extract(...) dict
  call archivitor#System('tar -xf', self.name, a:000)
endfunction

function! archivitor#tar#Update(...) dict
  let files = a:000

  if self.name =~ '\.tar$'
    call archivitor#System('tar -rf', self.name, files)
    return
  endif

  let cached_directory = s:CachedDir(self)
  call archivitor#System('cp -r', files, cached_directory)
  call s:UpdateFromCachedDir(self)
endfunction

function! archivitor#tar#Delete(paths) dict
  if self.name =~ '\.tar$'
    let paths = join(a:paths, ' ')
    call archivitor#System('tar --delete -f', self.name, paths)
    return
  endif

  let cached_directory = s:CachedDir(self)
  if len(glob(cached_directory.'/*', '', 1)) <= 1
    echoerr "Can't delete last file in archive"
    return
  endif

  let paths = join(map(a:paths, 'cached_directory."/".v:val'), ' ')

  call archivitor#System('rm -r', paths)
  call s:UpdateFromCachedDir(self)
endfunction

function! archivitor#tar#Add(path) dict
  if !filereadable(self.name)
    call archivitor#System('tar -caf', self.name, a:path)
    return
  endif

  if self.name =~ '\.tar$'
    call archivitor#System('tar -rf', self.name, a:path)
    return
  endif

  let cached_directory = s:CachedDir(self)
  call archivitor#System('cp -r', a:path, cached_directory)
  call s:UpdateFromCachedDir(self)
endfunction

function! s:CachedDir(archive)
  if has_key(s:cached_tempfiles, a:archive.name)
    return s:cached_tempfiles[a:archive.name]
  endif

  let tempdir = tempname()
  call mkdir(tempdir, 'p')

  let cwd = getcwd()
  exe 'cd '.tempdir
  call a:archive.Extract()
  exe 'cd '.cwd

  let s:cached_tempfiles[a:archive.name] = tempdir
  return s:cached_tempfiles[a:archive.name]
endfunction

function! s:UpdateFromCachedDir(archive)
  if !has_key(s:cached_tempfiles, a:archive.name)
    return
  endif

  let directory = s:cached_tempfiles[a:archive.name]

  let cwd = getcwd()
  exe 'cd '.directory
  call archivitor#System('tar -caf '.shellescape(a:archive.name).' *')
  exe 'cd '.cwd
endfunction
