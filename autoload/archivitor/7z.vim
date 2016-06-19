function! archivitor#7z#New(name)
  return {
        \ 'name':     a:name,
        \ 'readonly': 0,
        \
        \ 'Filelist': function('archivitor#7z#Filelist'),
        \ 'Extract':  function('archivitor#7z#Extract'),
        \ 'Update':   function('archivitor#7z#Update'),
        \ 'Add':      function('archivitor#7z#Add'),
        \ 'Delete':   function('archivitor#7z#Delete'),
        \ }
endfunction

function! archivitor#7z#Filelist() dict
  let file_list = []
  let files_started = 0
  let filename_column = -1

  for line in split(archivitor#util#SilentSystem('7z l', self.name), "\n")
    if line =~ '\s*Date\s*Time\s*Attr\s*Size\s*Compressed\s*Name'
      " the header, figure out where the files are
      let filename_column = stridx(line, 'Name')
    endif

    if line =~ '^---' && files_started
      " files have ended
      break
    endif

    if line =~ '^---'
      let files_started = 1
      continue
    endif

    if files_started
      if filename_column < 0
        echoerr "Can't parse 7z output."
        return []
      endif

      call add(file_list, strpart(line, filename_column))
    endif
  endfor

  return sort(file_list)
endfunction

function! archivitor#7z#Extract(...) dict
  call archivitor#util#System('7z x', self.name, a:000)
endfunction

function! archivitor#7z#Update(...) dict
  call archivitor#util#System('7z u', self.name, a:000)
endfunction

function! archivitor#7z#Delete(paths) dict
  call archivitor#util#System('7z d', self.name, a:paths)
endfunction

function! archivitor#7z#Add(path) dict
  call archivitor#util#System('7z a', self.name, a:path)
endfunction
