function! archivitor#EditFile(operation)
  let archive  = b:archive
  let filename = s:FilenameOnLine()
  let tempname = archive.Tempname(filename)

  exe a:operation.' '.escape(tempname, ' ')
  let b:archive = archive
  call b:archive.SetupWriteBehaviour(filename)
  command! -buffer Archive call b:archive.GotoBuffer() | call archivitor#RenderArchiveBuffer()
endfunction

function! archivitor#UpdateArchive()
  let saved_cursor = getpos('.')

  let files             = b:archive.Filelist()
  let remaining_indices = range(len(files))

  call cursor(1, 1)
  call search('=====', 'W')
  let first_line = nextnonblank(line('.') + 1)

  if first_line
    " then we have lines we need to parse
    for line in getline(first_line, line('$'))
      if line =~ '^\s*\d\+.'
        " then it's an existing entry
        let index_as_string = matchstr(line, '^\s*\d\+\ze.')
        let index           = str2nr(index_as_string)
        let path            = strpart(line, strlen(index_as_string) + 2)
        let original_path   = files[index]
        call remove(remaining_indices, index(remaining_indices, index))

        if original_path != path
          call b:archive.Rename(original_path, path)
        endif
      else
        " it's a new entry
        call b:archive.Add(line)
      endif
    endfor
  else
    " no lines, everything has been deleted, it seems
    call setpos('.', saved_cursor)
  endif

  let missing_files = map(remaining_indices, 'files[v:val]')
  if len(missing_files) > 0
    call b:archive.Delete(missing_files)
  endif

  call archivitor#RenderArchiveBuffer()

  call setpos('.', saved_cursor)
endfunction

function! archivitor#Enumerate(file_list)
  let file_count      = len(a:file_list)
  let width           = strlen(file_count - 1)
  let enumerated_list = []

  for i in range(file_count)
    call add(enumerated_list, printf('%'.width.'s. ', i).remove(a:file_list, 0))
  endfor

  return enumerated_list
endfunction

function! archivitor#RenderArchiveBuffer()
  %delete _

  let banner = []
  call add(banner, 'File:   ' . b:archive.name)
  call add(banner, 'Format: ' . b:archive.format)
  call add(banner, 'Size:   ' . b:archive.size)
  call add(banner, repeat('=', len(banner[0])))
  call append(0, banner)

  let contents = archivitor#Enumerate(b:archive.Filelist())
  set filetype=archive
  setlocal buftype=acwrite
  setlocal bufhidden=hide
  setlocal isfname+=:
  call append(line('$'), contents)
  normal! gg
  set nomodified
  let b:skip_clean_whitepaste = 1
endfunction

function! archivitor#ExternalOpenFile()
  let filename = s:FilenameOnLine()
  let real_path = b:archive.Tempname(filename)

  if exists('*OpenURL')
    call OpenURL(real_path)
  else
    call netrw#BrowseX(real_path, 0)
  endif
endfunction

function! s:FilenameOnLine()
  let line = getline('.')
  let line_number_pattern = '^\s*\d\+\. '

  if line !~ line_number_pattern
    return ''
  endif

  return substitute(line, line_number_pattern, '', '')
endfunction
