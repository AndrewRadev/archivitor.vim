let s:cached_tempfiles = {}

function! edit_archive#tar#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('edit_archive#tar#Filelist'),
        \ 'Extract':  function('edit_archive#tar#Extract'),
        \ 'Update':   function('edit_archive#tar#Update'),
        \ 'Add':      function('edit_archive#tar#Add'),
        \ 'Delete':   function('edit_archive#tar#Delete'),
        \ }
endfunction

function! edit_archive#tar#Filelist() dict
  let file_list = []
  for line in split(edit_archive#System('tar -tf ' . shellescape(self.name)), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return sort(file_list)
endfunction

function! edit_archive#tar#Extract(...) dict
  let files = join(a:000, ' ')
  call edit_archive#System('tar -xf '.shellescape(self.name).' '.files)
endfunction

function! edit_archive#tar#Update(...) dict
  let files = join(a:000, ' ')

  if self.name =~ '\.tar$'
    call edit_archive#System('tar -rf '.shellescape(self.name).' '.files)
    return
  endif

  let cached_directory = s:CachedDir(self)
  call edit_archive#System('cp -r '.files.' '.cached_directory)
  call s:UpdateFromCachedDir(self)
endfunction

function! edit_archive#tar#Delete(path) dict
  if self.name =~ '\.tar$'
    call edit_archive#System('tar --delete -f '.shellescape(self.name).' '.a:path)
    return
  endif

  let cached_directory = s:CachedDir(self)
  if len(glob(cached_directory.'/*', '', 1)) <= 1
    echoerr "Can't delete last file in archive"
    return
  endif

  call edit_archive#System('rm -r '.cached_directory.'/'.a:path)
  call s:UpdateFromCachedDir(self)
endfunction

function! edit_archive#tar#Add(path) dict
  if !filereadable(self.name)
    call edit_archive#System('tar -caf '.shellescape(self.name).' '.a:path)
    return
  endif

  if self.name =~ '\.tar$'
    call edit_archive#System('tar -rf '.shellescape(self.name).' '.a:path)
    return
  endif

  let cached_directory = s:CachedDir(self)
  call edit_archive#System('cp -r '.a:path.' '.cached_directory)
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
  call edit_archive#System('tar -caf '.a:archive.name.' *')
  exe 'cd '.cwd
endfunction
