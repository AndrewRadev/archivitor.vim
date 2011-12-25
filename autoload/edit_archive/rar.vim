function! edit_archive#rar#New(name)
  return extend(edit_archive#archive#Common(a:name), {
        \ 'readonly': 1,
        \
        \ 'FileList':    function('edit_archive#rar#FileList'),
        \ 'ExtractFile': function('edit_archive#rar#ExtractFile'),
        \ })
endfunction

function! edit_archive#rar#FileList() dict
  return sort(split(system('unrar vb ' . self.name), "\n"))
endfunction

function! edit_archive#rar#ExtractFile(filename) dict
  call system('unrar x '.self.name.' '.a:filename)
endfunction

function! edit_archive#archive#UpdateFile(archive_filename, real_filename) dict
  throw "RAR files are read-only"
endfunction
