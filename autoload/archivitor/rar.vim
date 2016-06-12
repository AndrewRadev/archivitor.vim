function! archivitor#rar#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 1,
        \
        \ 'Filelist': function('archivitor#rar#Filelist'),
        \ 'Extract':  function('archivitor#rar#Extract'),
        \ 'Update':   function('archivitor#rar#Update'),
        \ 'Add':      function('archivitor#rar#Add'),
        \ 'Delete':   function('archivitor#rar#Delete'),
        \ }
endfunction

function! archivitor#rar#Filelist() dict
  let initial_file_list = sort(split(archivitor#System('unrar vb', self.name), "\n"))

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

function! archivitor#rar#Extract(...) dict
  call archivitor#System('unrar x', self.name, a:000)
endfunction

function! archivitor#rar#Update(...) dict
  throw "RAR files are read-only"
endfunction

function! archivitor#rar#Add(...) dict
  throw "RAR files are read-only"
endfunction

function! archivitor#rar#Delete(...) dict
  throw "RAR files are read-only"
endfunction
