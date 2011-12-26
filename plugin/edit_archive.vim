autocmd BufReadCmd *.rar call s:ReadArchive(expand('<afile>'))
autocmd BufReadCmd *.zip call s:ReadArchive(expand('<afile>'))

function! s:ReadArchive(archive)
  exe 'edit '.tempname()
  let b:archive = edit_archive#archive#New(a:archive)

  let banner = []
  call add(banner, 'File: '   . b:archive.name)
  call add(banner, 'Format: ' . b:archive.format)
  call add(banner, 'Size: '   . b:archive.size)
  call add(banner, repeat('=', len(banner[0])))
  call append(0, banner)

  let contents = s:Enumerate(b:archive.Filelist())
  call append(line('$'), contents)
  normal! gg
  set filetype=archive
  set hidden

  nnoremap <buffer> <cr> :call <SID>EditFile()<cr>
  command! -buffer -nargs=1 -complete=dir Extract call b:archive.ExtractAll(<f-args>)
  autocmd BufWrite <buffer> call s:UpdateArchive()
endfunction

function! s:EditFile()
  let archive  = b:archive
  let filename = expand('<cfile>')
  let tempname = archive.Tempname(filename)

  exe 'edit '.tempname
  let b:archive = archive
  call b:archive.SetupWriteBehaviour(filename)
  command! -buffer Archive call b:archive.GotoBuffer()
endfunction

function! s:UpdateArchive()
  let saved_cursor = getpos('.')

  call cursor(0, 1)
  call search('=====', 'W')
  let first_line = nextnonblank(line('.'))
  if first_line <= 0
    call setpos('.', saved_cursor)
    return
  endif

  let files = b:archive.Filelist()
  for line in getline(first_line, line('$'))
    if line =~ '^\d\+.'
      " then it's an existing entry
      let index         = str2nr(matchstr(line, '^\d\+\ze.'))
      let path          = strpart(line, strlen(index) + 2)
      let original_path = files[index]

      if original_path != path
        call b:archive.Rename(original_path, path)
      endif
    endif
  endfor

  call setpos('.', saved_cursor)
endfunction

function! s:Enumerate(file_list)
  let file_count      = len(a:file_list)
  let width           = strlen(file_count - 1)
  let enumerated_list = []

  for i in range(file_count)
    call add(enumerated_list, printf('%'.width.'s. ', i).remove(a:file_list, 0))
  endfor

  return enumerated_list
endfunction
