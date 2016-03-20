function! edit_archive#archive#New(name)
  let name = fnameescape(fnamemodify(a:name, ':p'))

  " Filetype dispatch
  if a:name =~ '\.rar$'
    let format  = 'rar'
    let backend = edit_archive#rar#New(name)
  elseif a:name =~ '\.zip$'
    let format  = 'zip'
    let backend = edit_archive#zip#New(name)
  elseif a:name =~ '\.tar\%(\.\%(gz\|bz2\|xz\)\)\?$'
    let format  = 'tar'
    let backend = edit_archive#tar#New(name)
  else
    throw "Unrecognized archive"
  endif

  let tempdir = tempname()
  call mkdir(tempdir, 'p')

  return {
        \ 'backend':  backend,
        \ 'name':     name,
        \ 'format':   format,
        \
        \ 'size':    s:Filesize(a:name),
        \ 'tempdir': tempdir,
        \ 'bufnr':   bufnr('%'),
        \
        \ 'Filelist':            function('edit_archive#archive#Filelist'),
        \ 'Add':                 function('edit_archive#archive#Add'),
        \ 'Rename':              function('edit_archive#archive#Rename'),
        \ 'Delete':              function('edit_archive#archive#Delete'),
        \ 'GotoBuffer':          function('edit_archive#archive#GotoBuffer'),
        \ 'ExtractAll':          function('edit_archive#archive#ExtractAll'),
        \ 'Tempname':            function('edit_archive#archive#Tempname'),
        \ 'SetupWriteBehaviour': function('edit_archive#archive#SetupWriteBehaviour'),
        \ 'UpdateFile':          function('edit_archive#archive#UpdateFile'),
        \ 'UpdateInfo':          function('edit_archive#archive#UpdateInfo'),
        \ }
endfunction

function! edit_archive#archive#Filelist() dict
  if filereadable(self.name)
    return self.backend.Filelist()
  else
    return []
  endif
endfunction

function! edit_archive#archive#Rename(old_path, new_path) dict
  let tempfile = self.Tempname(a:old_path)
  call self.backend.Delete(a:old_path)

  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call rename(a:old_path, a:new_path)
  return self.backend.Add(a:new_path)
  exe 'cd '.cwd
endfunction

function! edit_archive#archive#GotoBuffer() dict
  exe 'buffer '.self.bufnr
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
    augroup edit_archive_write_behaviour
      autocmd!
      autocmd BufWritePost <buffer> call b:archive.UpdateFile(expand('<amatch>'))
    augroup END
  endif
endfunction

function! edit_archive#archive#UpdateFile(filename) dict
  let real_filename    = a:filename
  let archive_filename = substitute(a:filename, '^\V'.self.tempdir.'/', '', '')

  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call self.backend.Update(archive_filename)
  exe 'cd '.cwd
  call self.UpdateInfo()
endfunction

function! edit_archive#archive#Tempname(filename) dict
  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call self.backend.Extract(a:filename)
  exe 'cd '.cwd

  return self.tempdir.'/'.a:filename
endfunction

function! edit_archive#archive#Add(path) dict
  let cwd = getcwd()
  exe 'cd '.self.tempdir

  if a:path =~ '/$'
    if isdirectory(a:path)
      call edit_archive#System('rm -r '.a:path)
    endif
    call mkdir(a:path, 'p')
  else
    let parent_dir = fnamemodify(a:path, ':h')
    if !isdirectory(parent_dir)
      call mkdir(parent_dir, 'p')
    endif
    call edit_archive#System('touch '.a:path)
  endif

  call self.backend.Add(a:path)
  call self.UpdateInfo()

  exe 'cd '.cwd
endfunction

function! edit_archive#archive#Delete(path) dict
  call self.backend.Delete(a:path)
  call self.UpdateInfo()
endfunction

function! s:Filesize(filename)
  if !filereadable(a:filename)
    return '0B (new)'
  endif

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

function! edit_archive#archive#UpdateInfo() dict
  let self.size = s:Filesize(self.name)
endfunction
