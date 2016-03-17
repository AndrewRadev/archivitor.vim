function! edit_archive#rar#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 1,
        \
        \ 'Filelist': function('edit_archive#rar#Filelist'),
        \ 'Extract':  function('edit_archive#rar#Extract'),
        \ 'Update':   function('edit_archive#rar#Update'),
        \ 'Add':      function('edit_archive#rar#Add'),
        \ 'Delete':   function('edit_archive#rar#Delete'),
        \ }
endfunction

function! edit_archive#rar#Filelist() dict
  let initial_file_list = sort(split(edit_archive#System('unrar vb ' . self.name), "\n"))

  let files       = []
  let directories = []

  " need to separate files and directories
  while len(initial_file_list) > 0
    let file = remove(initial_file_list, 0)
    let is_directory = 0

    for other_file in initial_file_list
      if stridx(other_file, file.'/') >= 0
        let is_directory = 1
        call add(directories, file.'/')
        break
      endif
    endfor

    if !is_directory
      call add(files, file)
    endif
  endwhile

  return sort(files + directories)
endfunction

function! edit_archive#rar#Extract(...) dict
  let files = join(a:000, ' ')
  call edit_archive#System('unrar x '.self.name.' '.files)
endfunction

function! edit_archive#rar#Update(...) dict
  throw "RAR files are read-only"
endfunction

function! edit_archive#rar#Add(...) dict
  throw "RAR files are read-only"
endfunction

function! edit_archive#rar#Delete(...) dict
  throw "RAR files are read-only"
endfunction
