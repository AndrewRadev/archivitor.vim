function! edit_archive#System(command)
  let result = system(a:command)
  if v:shell_error
    echoerr "System error: ".result
  endif
  return result
endfunction
