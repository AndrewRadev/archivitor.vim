function! archivitor#archive#New(name)
  let name = fnamemodify(a:name, ':p')

  " Filetype dispatch
  if a:name =~ '\.rar$'
    let format  = 'rar'
    let backend = archivitor#rar#New(name)
  elseif a:name =~ '\.7z$'
    let format  = '7z'
    let backend = archivitor#7z#New(name)
  elseif a:name =~ '\.zip$'
    let format  = 'zip'
    let backend = archivitor#zip#New(name)
  elseif a:name =~ '\.tar\%(\.\%(gz\|bz2\|xz\)\)\?$'
    let format  = 'tar'
    let backend = archivitor#tar#New(name)
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
        \ 'Filelist':            function('archivitor#archive#Filelist'),
        \ 'Add':                 function('archivitor#archive#Add'),
        \ 'Rename':              function('archivitor#archive#Rename'),
        \ 'Delete':              function('archivitor#archive#Delete'),
        \ 'GotoBuffer':          function('archivitor#archive#GotoBuffer'),
        \ 'ExtractAll':          function('archivitor#archive#ExtractAll'),
        \ 'Tempname':            function('archivitor#archive#Tempname'),
        \ 'SetupWriteBehaviour': function('archivitor#archive#SetupWriteBehaviour'),
        \ 'UpdateFile':          function('archivitor#archive#UpdateFile'),
        \ 'UpdateInfo':          function('archivitor#archive#UpdateInfo'),
        \ }
endfunction

function! archivitor#archive#Filelist() dict
  if filereadable(self.name)
    return self.backend.Filelist()
  else
    return []
  endif
endfunction

function! archivitor#archive#Rename(old_path, new_path) dict
  let tempfile = self.Tempname(a:old_path)
  call self.backend.Delete([a:old_path])

  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call rename(a:old_path, a:new_path)
  return self.backend.Add(a:new_path)
  exe 'cd '.cwd
endfunction

function! archivitor#archive#GotoBuffer() dict
  exe 'buffer '.self.bufnr
endfunction

function! archivitor#archive#ExtractAll(dir) dict
  let dir = fnamemodify(a:dir, ':p')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif

  let cwd = getcwd()
  exe 'cd '.dir
  call self.backend.Extract()
  exe 'cd '.cwd
endfunction

function! archivitor#archive#SetupWriteBehaviour(filename) dict
  if self.backend.readonly
    set readonly
  else
    augroup edit_archive_write_behaviour
      autocmd!
      autocmd BufWritePost <buffer> call b:archive.UpdateFile(expand('<amatch>'))
    augroup END
  endif
endfunction

function! archivitor#archive#UpdateFile(filename) dict
  let real_filename    = a:filename
  let archive_filename = substitute(a:filename, '^\V'.self.tempdir.'/', '', '')

  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call self.backend.Update(archive_filename)
  exe 'cd '.cwd
  call self.UpdateInfo()
endfunction

function! archivitor#archive#Tempname(filename) dict
  let cwd = getcwd()
  exe 'cd '.self.tempdir
  call self.backend.Extract(a:filename)
  exe 'cd '.cwd

  return self.tempdir.'/'.a:filename
endfunction

function! archivitor#archive#Add(path) dict
  let cwd = getcwd()
  exe 'cd '.self.tempdir

  if a:path =~ '/$'
    if isdirectory(a:path)
      call archivitor#System('rm -r', a:path)
    endif
    call mkdir(a:path, 'p')
  else
    let parent_dir = fnamemodify(a:path, ':h')
    if !isdirectory(parent_dir)
      call mkdir(parent_dir, 'p')
    endif
    call archivitor#System('touch', a:path)
  endif

  call self.backend.Add(a:path)
  call self.UpdateInfo()

  exe 'cd '.cwd
endfunction

function! archivitor#archive#Delete(paths) dict
  for path_batch in archivitor#Group(a:paths, 100)
    call self.backend.Delete(path_batch)
  endfor
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

function! archivitor#archive#UpdateInfo() dict
  let self.size = s:Filesize(self.name)
endfunction
