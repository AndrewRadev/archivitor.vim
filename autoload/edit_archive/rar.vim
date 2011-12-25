function! edit_archive#rar#New(name)
  return extend(edit_archive#archive#Common(a:name), {
        \ 'readonly': 1,
        \
        \ 'FileList': function('edit_archive#rar#FileList'),
        \ 'Extract':  function('edit_archive#rar#Extract'),
        \ })
endfunction

function! edit_archive#rar#FileList() dict
  return sort(split(system('unrar vb ' . self.name), "\n"))
endfunction

function! edit_archive#rar#Extract(...) dict
  let files = join(a:000, ' ')
  call system('unrar x '.self.name.' '.files)
endfunction

function! edit_archive#archive#Update(...) dict
  throw "RAR files are read-only"
endfunction
