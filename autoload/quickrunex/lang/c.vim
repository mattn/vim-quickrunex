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
\ ['^gtk[./]', ['`pkg-config --cflags gtk+-2.0`', '`pkg-config --libs gtk+-2.0`']],
\]

let s:hook = {}

function! quickrunex#lang#c#apply(session, context)
  let flags =  quickrunex#lang#{&ft}#get_flags()
  let mx = '^\s*#\s*include\s\+[<"]\zs[^">]\+\ze[">]'
  let [n, l] = [1, line('$')]
  let exec = a:session['config']['exec']
  let is_msvc = a:session['config']['command'] == 'cl'
  while n < l
    let file = matchstr(getline(n), mx)
    if len(file)
      for inf in flags
        if file =~ inf[0]
          for v in range(len(exec))
            if stridx(exec[v], '%c') != -1 && stridx(exec[v], inf[1][0]) == -1
              let f = ' '.substitute(inf[1][0], '`\([^`]\+\)`', '\=system(s:fixup_backquote(is_msvc, submatch(1)))', 'g')
              if has('win32') || has('win64')
                let f = s:fixup_libs(is_msvc, f)
              endif
              let exec[v] .= ' '.f
            endif
          endfor
          for v in range(len(exec))
            if stridx(exec[v], '%c') != -1 && stridx(exec[v], inf[1][1]) == -1
              if is_msvc
                let exec[v] .= ' /link'
              endif
              let f = ' '.substitute(inf[1][1], '`\([^`]\+\)`', '\=system(s:fixup_backquote(is_msvc, submatch(1)))', 'g')
              if has('win32') || has('win64')
                let f = s:fixup_libs(is_msvc, f)
              endif
              let exec[v] .= ' '.f
            endif
          endfor
        endif
      endfor
    endif
    let n += 1
  endwhile
endfunction

function! s:shellwords(str)
  let words = split(a:str, '\%(\([^ \t\''"]\+\)\|''\([^\'']*\)''\|"\(\%([^\"\\]\|\\.\)*\)"\)\zs\s*\ze')
  let words = map(words, 'substitute(v:val, ''\\\([\\ ]\)'', ''\1'', "g")')
  let words = map(words, 'matchstr(v:val, ''^\%\("\zs\(.*\)\ze"\|''''\zs\(.*\)\ze''''\|.*\)$'')')
  return words
endfunction

function! s:fixup_backquote(is_msvc, cmd)
  if !a:is_msvc | return a:cmd | endif
  let cmd = a:cmd
  let cmd = substitute(cmd, 'pkg-config ', 'pkg-config --msvc-syntax ', 'g')
  return cmd
endfunction

function! s:which(cmd)
  let ret = globpath(substitute(substitute($PATH, ';', ',', 'g'), '\', '/', 'g'), a:cmd)
  return len(ret) == 0 ? '' : substitute(split(ret, "\n")[0], '\', '/', 'g')
endfunction

function! s:fixup_libs(is_msvc, flags)
  let flags = a:flags
  if a:is_msvc
    let flags = substitute(flags, '-mms-bitfields', '', 'g')
    let cl = s:which('cl.exe')
    if len(cl) == 0
      return flags
    endif
    let libpath = substitute(cl, '/bin/cl\.exe$', '/lib', '')
    let libs = s:shellwords(flags)
    for n in range(len(libs))
      if libs[n] =~ '^-l'
        let l = split(globpath(libpath, libs[n][2:].'*.lib'), "\n")
        if len(l)
          let l = map(l, 'fnamemodify(v:val, ":t")')
          let libs[n] = sort(l)[0]
        endif
      endif
    endfor
    return join(libs, ' ')
  else
    let gcc = s:which('gcc.exe')
    if len(gcc) == 0
      return flags
    endif
    let libpath = substitute(gcc, '/bin/gcc\.exe$', '/lib', '')
    let libs = s:shellwords(flags)
    for n in range(len(libs))
      if libs[n] =~ '^-l'
        let l = split(globpath(libpath, 'lib'.libs[n][2:].'*.a'), "\n")
        if len(l)
          let l = map(l, 'fnamemodify(v:val, ":t")')
          let l = map(l, 'substitute(v:val, "^lib", "-l", "")')
          let l = map(l, 'substitute(v:val, "\.a$", "", "")')
          let libs[n] = sort(l)[0]
        endif
      endif
    endfor
    return join(libs, ' ')
  endif
endfunction

function! quickrunex#lang#c#get_flags()
  return s:flags
endfunction
