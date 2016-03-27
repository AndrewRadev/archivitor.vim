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
  let file_line_pattern = '\v^\s*\d+\s*\d+-\d+-\d+\s*\d+:\d+\s*(.*)$'
  let file_list = []

  for line in split(edit_archive#SilentSystem('unzip -qql ' . shellescape(self.name)), "\n")
    if line =~ file_line_pattern
      call add(file_list, substitute(line, file_line_pattern, '\1', ''))
    endif
  endfor
  return sort(file_list)
endfunction

function! edit_archive#zip#Extract(...) dict
  let files = join(a:000, ' ')
  call edit_archive#System('unzip -o '.shellescape(self.name).' '.files)
endfunction

function! edit_archive#zip#Update(...) dict
  let files = join(a:000, ' ')
  call edit_archive#System('zip -u '.shellescape(self.name).' '.files)
endfunction

function! edit_archive#zip#Delete(paths) dict
  let paths = join(a:paths, ' ')
  call edit_archive#System('zip '.shellescape(self.name).' -d '.paths)
endfunction

function! edit_archive#zip#Add(path) dict
  call edit_archive#System('zip -r '.shellescape(self.name).' '.a:path)
endfunction
