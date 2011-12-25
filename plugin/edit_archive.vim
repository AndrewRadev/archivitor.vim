autocmd BufReadCmd *.rar call s:ReadArchive(expand('<afile>'))
autocmd BufReadCmd *.zip call s:ReadArchive(expand('<afile>'))

function! s:ReadArchive(archive)
  exe 'edit '.tempname()
  let b:archive = edit_archive#archive#New(a:archive)

  let banner = ['File: '.b:archive.name]
  let banner += [repeat('=', len(banner[0]))]
  call append(0, banner)

  let contents = b:archive.FileList()
  call append(line('$'), contents)
  normal! gg
  set readonly

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
