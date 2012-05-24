" libuv
let s:flags = [
\ ['^\(uv.h\|uv/uv.h\)$', ['', '-luv']],
\]

" v8
if has('win32') || has('win64')
  let s:flags += [
  \ ['^v8[./]', ['', '-lv8 -lws2_32 -lwinmm']],
  \]
else
  let s:flags += [
  \ ['^v8[./]', ['', '-lv8']],
  \]
endif

" gtk
let s:flags += [
\ ['^gtk[./]', ['`pkg-config --cflags --libs gtk+-2.0`', '']],
\]

let s:hook = {}

function! s:hook.on_hook_loaded(session, context)
  let flags = []
  for lang in self['lang']
    let flags += quickrunex#lang#{lang}#get_flags()
  endfor

  let mx = '^\s*#\s*include\s\+[<"]\zs[^">]\+\ze[">]'
  let [n, l] = [1, line('$')]
  let exec = a:session['config']['exec']
  while n < l
    let file = matchstr(getline(n), mx)
    if len(file)
      for inf in flags
        if file =~ inf[0]
          for v in range(len(exec))
            if stridx(exec[v], '%c') != -1 && stridx(exec[v], inf[1][0]) == -1
              let exec[v] .= ' '.substitute(inf[1][0], '`\(.\+\)`', '\=system(submatch(1))', 'g')
            endif
          endfor
          for v in range(len(exec))
            if stridx(exec[v], '%c') != -1 && stridx(exec[v], inf[1][1]) == -1
              let flags = ' '.substitute(inf[1][1], '`\(.\+\)`', '\=system(submatch(1))', 'g')
              if has('win32') || has('win64')
                let flags = s:fixup_mingw_libs(flags)
              endif
              let exec[v] .= ' '.flags
            endif
          endfor
        endif
      endfor
    endif
    let n += 1
  endwhile
endfunction

function! s:fixup_mingw_libs(flags)
  let gccs = split(globpath(substitute($PATH, ';', ',', 'g'), 'gcc.exe'), "\n")
  if len(gccs) == 0
    return a:flags
  endif
  let gcc = substitute(gccs[0], '\', '/', 'g')
  let libpath = substitute(gcc, '/bin/gcc\.exe$', '/lib', '')
  let libs = split(a:flags, '\s\+')
  for n in range(len(libs))
    if libs[n] =~ '^-l'
      let l = split(globpath(libpath, 'lib'.libs[n][2:].'*.a'), "\n")
      if len(l)
        let l = map(l, 'substitute(v:val, ".*\\", "", "")')
        let l = map(l, 'substitute(v:val, "^lib", "-l", "")')
        let l = map(l, 'substitute(v:val, "\.a$", "", "")')
        let libs[n] = sort(l)[0]
      endif
    endif
  endfor
  return join(libs, ' ')
endfunction

let s:fixup_mingw = 0
function! quickrunex#lang#c#get_hook()
  return s:hook
endfunction

function! quickrunex#lang#c#get_flags()
  return s:flags
endfunction

function! quickrunex#lang#c#install()
  let hook = quickrunex#lang#c#get_hook()
  let hook['lang'] = ['c']
  call quickrun#register_hook('quickrunex', hook)
endfunction
