function! edit_archive#archive#New(name)
  if a:name =~ '\.rar$'
    return edit_archive#rar#New(a:name)
  elseif a:name =~ '\.zip$'
    return edit_archive#zip#New(a:name)
  else
    throw "Unrecognized archive"
  endif
endfunction

function! edit_archive#archive#Common(name)
  return {
        \ 'name':     fnamemodify(a:name, ':p'),
        \ 'readonly': 0,
        \ '_tempdir': '',
        \
        \ 'FileList':    function('edit_archive#archive#FileList'),
        \ 'ExtractFile': function('edit_archive#archive#ExtractFile'),
        \ 'UpdateFile':  function('edit_archive#archive#UpdateFile'),
        \
        \ 'Tempname':            function('edit_archive#archive#Tempname'),
        \ 'SetupWriteBehaviour': function('edit_archive#archive#SetupWriteBehaviour'),
        \ 'UpdateArchive':       function('edit_archive#archive#UpdateArchive'),
        \ }
endfunction

function! edit_archive#archive#FileList() dict
  throw "not implemented"
endfunction

function! edit_archive#archive#ExtractFile(filename) dict
  throw "not implemented"
endfunction

function! edit_archive#archive#UpdateFile(archive_filename, real_filename) dict
  throw "not implemented"
endfunction

function! edit_archive#archive#SetupWriteBehaviour(filename) dict
  if self.readonly
    set readonly
  else
    autocmd BufWritePost <buffer> call b:archive.UpdateArchive(expand('<amatch>'))
  endif
endfunction

function! edit_archive#archive#UpdateArchive(filename) dict
  let real_filename    = a:filename
  let archive_filename = substitute(a:filename, '^\V'.self._tempdir.'/', '', '')

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.UpdateFile(archive_filename)
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#Tempname(filename) dict
  if self._tempdir == ''
    let self._tempdir = tempname()
    call mkdir(self._tempdir)
  endif

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.ExtractFile(a:filename)
  exe 'cd '.cwd

  return self._tempdir.'/'.a:filename
endfunction