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

  let contents = b:archive.FileList()
  call append(line('$'), contents)
  normal! gg
  set readonly
  set filetype=archive

  nnoremap <buffer> <cr> :call <SID>EditFile()<cr>
  command! -nargs=1 -complete=dir Extract call b:archive.ExtractAll(<f-args>)
endfunction

function! s:EditFile()
  let archive  = b:archive
  let filename = expand('<cfile>')
  let tempname = archive.Tempname(filename)

  exe 'edit '.tempname
  let b:archive = archive
  call b:archive.SetupWriteBehaviour(filename)
endfunction
