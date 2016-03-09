function! edit_archive#targz#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('edit_archive#targz#Filelist'),
        \ 'Extract':  function('edit_archive#targz#Extract'),
        \ 'Update':   function('edit_archive#targz#Update'),
        \ 'Add':      function('edit_archive#targz#Add'),
        \ 'Delete':   function('edit_archive#targz#Delete'),
        \ }
endfunction

function! edit_archive#targz#Filelist() dict
  let file_list = []
  for line in split(system('tar -tf ' . self.name), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return sort(file_list)
endfunction

function! edit_archive#targz#Extract(...) dict
  let files = join(a:000, ' ')
  call system('tar -xf '.self.name.' '.files)
endfunction

" TODO (2016-03-09) Doesn't work with compressed archives...
function! edit_archive#targz#Update(...) dict
  throw "Not implemented"
  " let files = join(a:000, ' ')
  " call system('tar -rf '.self.name.' '.files)
endfunction

function! edit_archive#targz#Delete(path) dict
  throw "Not implemented"
  " call system('targz -r '.self.name.' -d '.a:path)
endfunction

function! edit_archive#targz#Add(path) dict
  throw "Not implemented"
  " call system('targz -r '.self.name.' '.a:path)
endfunction
