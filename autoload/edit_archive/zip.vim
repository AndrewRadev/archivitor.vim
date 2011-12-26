function! edit_archive#zip#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('edit_archive#zip#Filelist'),
        \ 'Extract':  function('edit_archive#zip#Extract'),
        \ 'Update':   function('edit_archive#zip#Update'),
        \ 'Add':      function('edit_archive#zip#Add'),
        \ 'Delete':   function('edit_archive#zip#Delete'),
        \ }
endfunction

function! edit_archive#zip#Filelist() dict
  let file_list = []
  for line in split(system('unzip -qql ' . self.name), "\n")
    call add(file_list, substitute(line, '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$', '\1', ''))
  endfor
  return sort(file_list)
endfunction

function! edit_archive#zip#Extract(...) dict
  let files = join(a:000, ' ')
  call system('unzip '.self.name.' '.files)
endfunction

function! edit_archive#zip#Update(...) dict
  let files = join(a:000, ' ')
  call system('zip -u '.self.name.' '.files)
endfunction

function! edit_archive#zip#Delete(path) dict
  call system('zip -r '.self.name.' -d '.a:path)
endfunction

function! edit_archive#zip#Add(path) dict
  call system('zip -r '.self.name.' '.a:path)
endfunction
