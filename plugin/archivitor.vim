" Prevent built-in tar and zip plugins from loading
let g:loaded_tarPlugin = 1
let g:loaded_tar       = 1
let g:loaded_zipPlugin = 1
let g:loaded_zip       = 1

" Disable tar/zip plugin if it's loaded anyway
augroup tar
  autocmd!
augroup END
augroup zip
  autocmd!
augroup END

augroup archivitor
  autocmd!

  autocmd BufReadCmd *.zip             call archivitor#ReadArchive(expand('<afile>'))
  autocmd BufReadCmd *.rar             call archivitor#ReadArchive(expand('<afile>'))
  autocmd BufReadCmd *.7z              call archivitor#ReadArchive(expand('<afile>'))
  autocmd BufReadCmd *.tar             call archivitor#ReadArchive(expand('<afile>'))
  autocmd BufReadCmd *.tar.{gz,bz2,xz} call archivitor#ReadArchive(expand('<afile>'))

  autocmd BufWriteCmd *.zip             call archivitor#UpdateArchive()
  autocmd BufWriteCmd *.rar             call archivitor#UpdateArchive()
  autocmd BufWriteCmd *.7z              call archivitor#UpdateArchive()
  autocmd BufWriteCmd *.tar             call archivitor#UpdateArchive()
  autocmd BufWriteCmd *.tar.{gz,bz2,xz} call archivitor#UpdateArchive()
augroup END

function! archivitor#ReadArchive(archive)
  let b:archive = archivitor#archive#New(a:archive)
  call archivitor#RenderArchiveBuffer()

  nnoremap <buffer> <cr>       :call archivitor#EditFile('edit')<cr>
  nnoremap <buffer> gf         :call archivitor#EditFile('edit')<cr>
  nnoremap <buffer> <c-w>f     :call archivitor#EditFile('split')<cr>
  nnoremap <buffer> <c-w><c-f> :call archivitor#EditFile('split')<cr>
  nnoremap <buffer> <c-w>gf    :call archivitor#EditFile('tabedit')<cr>

  command! -buffer -nargs=1 -complete=dir Extract call b:archive.ExtractAll(<f-args>)
endfunction
