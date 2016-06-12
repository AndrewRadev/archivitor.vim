function! archivitor#zip#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('archivitor#zip#Filelist'),
        \ 'Extract':  function('archivitor#zip#Extract'),
        \ 'Update':   function('archivitor#zip#Update'),
        \ 'Add':      function('archivitor#zip#Add'),
        \ 'Delete':   function('archivitor#zip#Delete'),
        \ }
endfunction

function! archivitor#zip#Filelist() dict
  let file_line_pattern = '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$'
  let file_list = []

  for line in split(archivitor#SilentSystem('unzip -qql', self.name), "\n")
    if line =~ file_line_pattern
      call add(file_list, substitute(line, file_line_pattern, '\1', ''))
    endif
  endfor
  return sort(file_list)
endfunction

function! archivitor#zip#Extract(...) dict
  call archivitor#System('unzip -o', self.name, a:000)
endfunction

function! archivitor#zip#Update(...) dict
  call archivitor#System('zip -u', self.name, a:000)
endfunction

function! archivitor#zip#Delete(paths) dict
  call archivitor#System('zip', self.name, {'-d': a:paths})
endfunction

function! archivitor#zip#Add(path) dict
  call archivitor#System('zip', self.name, {'-r': a:path})
endfunction
