let s:hook = {}

function! s:hook.on_module_loaded(session, context)
  try
    call quickrunex#lang#{&ft}#apply(a:session, a:context)
  catch
  endtry
endfunction

function! quickrun#hook#quickrunex#new()
  return deepcopy(s:hook)
endfunction
