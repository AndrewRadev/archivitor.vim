function! edit_archive#rar#New(name)
  return extend(edit_archive#archive#Common(a:name), {
        \ 'readonly': 1,
        \
        \ 'FileList': function('edit_archive#rar#FileList'),
        \ 'Extract':  function('edit_archive#rar#Extract'),
        \ })
endfunction

function! edit_archive#rar#FileList() dict
  let initial_file_list = sort(split(system('unrar vb ' . self.name), "\n"))

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
  call system('unrar x '.self.name.' '.files)
endfunction

function! edit_archive#archive#Update(...) dict
  throw "RAR files are read-only"
endfunction
