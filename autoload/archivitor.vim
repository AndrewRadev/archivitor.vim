function! archivitor#System(command)
  let result = system(a:command)
  if v:shell_error
    echoerr "System error: ".result
  endif
  return result
endfunction

function! archivitor#SilentSystem(command)
  return system(a:command)
endfunction
