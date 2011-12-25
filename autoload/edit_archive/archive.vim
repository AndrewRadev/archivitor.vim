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
        \ 'format':   fnamemodify(a:name, ':e'),
        \ 'size':     s:Filesize(a:name),
        \ 'readonly': 0,
        \ '_tempdir': '',
        \ '_bufnr':   bufnr('%'),
        \
        \ 'FileList': function('edit_archive#archive#FileList'),
        \ 'Extract':  function('edit_archive#archive#Extract'),
        \ 'Update':   function('edit_archive#archive#Update'),
        \ 'Rename':   function('edit_archive#archive#Rename'),
        \
        \ 'GotoBuffer':          function('edit_archive#archive#GotoBuffer'),
        \ 'ExtractAll':          function('edit_archive#archive#ExtractAll'),
        \ 'Tempname':            function('edit_archive#archive#Tempname'),
        \ 'SetupWriteBehaviour': function('edit_archive#archive#SetupWriteBehaviour'),
        \ 'UpdateArchive':       function('edit_archive#archive#UpdateArchive'),
        \ }
endfunction

function! edit_archive#archive#FileList() dict
  throw 'not implemented'
endfunction

function! edit_archive#archive#Extract(...) dict
  throw 'not implemented'
endfunction

function! edit_archive#archive#Update(...) dict
  throw 'not implemented'
endfunction

function! edit_archive#archive#Rename(old_name, new_name) dict
  let tempfile = self.Tempname(a:old_name)
  call system('zip -r '.self.name.' -d '.a:old_name)

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call rename(a:old_name, a:new_name)
  call system('zip -r '.self.name.' '.a:new_name)
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#GotoBuffer() dict
  exe 'buffer '.self._bufnr
endfunction

function! edit_archive#archive#ExtractAll(dir) dict
  let dir = fnamemodify(a:dir, ':p')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif

  let cwd = getcwd()
  exe 'cd '.dir
  call self.Extract()
  exe 'cd '.cwd
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
  call self.Update(archive_filename)
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#Tempname(filename) dict
  if self._tempdir == ''
    let self._tempdir = tempname()
    call mkdir(self._tempdir)
  endif

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.Extract(a:filename)
  exe 'cd '.cwd

  return self._tempdir.'/'.a:filename
endfunction

function! s:Filesize(filename)
  let bytes = getfsize(a:filename)

  if bytes >= 1024 * 1024
    let size = string(bytes / (1024.0 * 1024.0)) . 'MB'
  elseif bytes >= 1024
    let size = string(bytes / 1024.0) . 'KB'
  else
    let size = string(bytes).'B'
  endif

  let size = substitute(size, '\.\d\d\zs\d\+\ze\w', '', '')

  return size
endfunction
