function! edit_archive#tar#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('edit_archive#tar#Filelist'),
        \ 'Extract':  function('edit_archive#tar#Extract'),
        \ 'Update':   function('edit_archive#tar#Update'),
        \ 'Add':      function('edit_archive#tar#Add'),
        \ 'Delete':   function('edit_archive#tar#Delete'),
        \ }
endfunction

function! edit_archive#tar#Filelist() dict
  let file_list = []
  for line in split(system('tar -tf ' . self.name), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return sort(file_list)
endfunction

function! edit_archive#tar#Extract(...) dict
  let files = join(a:000, ' ')
  call system('tar -xf '.self.name.' '.files)
endfunction

" TODO (2016-03-09) Doesn't work with compressed archives...
function! edit_archive#tar#Update(...) dict
  throw "Not implemented"
endfunction

function! edit_archive#tar#Delete(path) dict
  throw "Not implemented"
  " call system('tar -r '.self.name.' -d '.a:path)
endfunction

function! edit_archive#tar#Add(path) dict
  if self.name =~ '\.tar$'
    call system('tar -rf '.self.name.' '.a:path)
  else
    throw "Not implemented for archived tar files"
  endif
endfunction
