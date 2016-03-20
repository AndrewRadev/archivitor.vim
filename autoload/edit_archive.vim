function! edit_archive#System(command)
  let result = system(a:command)
  if v:shell_error
    echoerr "System error: ".result
  endif
  return result
endfunction

function! edit_archive#SilentSystem(command)
  return system(a:command)
endfunction
