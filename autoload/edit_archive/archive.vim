function! edit_archive#archive#New(name)
  let name = fnamemodify(a:name, ':p')

  if a:name =~ '\.rar$'
    let format  = 'rar'
    let backend = edit_archive#rar#New(name)
  elseif a:name =~ '\.zip$'
    let format  = 'zip'
    let backend = edit_archive#zip#New(name)
  else
    throw "Unrecognized archive"
  endif

  return {
        \ 'backend':  backend,
        \ 'name':     name,
        \ 'format':   format,
        \
        \ 'size':     s:Filesize(a:name),
        \ '_tempdir': '',
        \ '_bufnr':   bufnr('%'),
        \
        \ 'Filelist':            function('edit_archive#archive#Filelist'),
        \ 'Rename':              function('edit_archive#archive#Rename'),
        \ 'GotoBuffer':          function('edit_archive#archive#GotoBuffer'),
        \ 'ExtractAll':          function('edit_archive#archive#ExtractAll'),
        \ 'Tempname':            function('edit_archive#archive#Tempname'),
        \ 'SetupWriteBehaviour': function('edit_archive#archive#SetupWriteBehaviour'),
        \ 'UpdateFile':          function('edit_archive#archive#UpdateFile'),
        \ }
endfunction

function! edit_archive#archive#Filelist() dict
  return self.backend.Filelist()
endfunction

function! edit_archive#archive#Rename(old_path, new_path) dict
  let tempfile = self.Tempname(a:old_path)
  call self.backend.Delete(a:old_path)

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call rename(a:old_path, a:new_path)
  return self.backend.Add(a:new_path)
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
  call self.backend.Extract()
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#SetupWriteBehaviour(filename) dict
  if self.backend.readonly
    set readonly
  else
    autocmd BufWritePost <buffer> call b:archive.UpdateFile(expand('<amatch>'))
  endif
endfunction

function! edit_archive#archive#UpdateFile(filename) dict
  let real_filename    = a:filename
  let archive_filename = substitute(a:filename, '^\V'.self._tempdir.'/', '', '')

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.backend.Update(archive_filename)
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#Tempname(filename) dict
  if self._tempdir == ''
    let self._tempdir = tempname()
    call mkdir(self._tempdir)
  endif

  let cwd = getcwd()
  exe 'cd '.self._tempdir
  call self.backend.Extract(a:filename)
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
