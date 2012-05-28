" boost
let s:flags = [
\ ['^boost/chrono[./]', ['', '-lboost_chrono -lboost_system']],
\ ['^boost/date_time[./]', ['', '-lboost_date_time']],
\ ['^boost/exception[./]', ['', '-lboost_exception']],
\ ['^boost/filesystem[./]', ['', '-lboost_filesystem -lboost_system']],
\ ['^boost/graph[./]', ['', '-lboost_graph']],
\ ['^boost/iostreams[./]', ['', '-lboost_iostreams']],
\ ['^boost/locale[./]', ['', '-lboost_locale']],
\ ['^boost/math[./]', ['', '-lboost_math_c99']],
\ ['^boost/python[./]', ['', '-lboost_python']],
\ ['^boost/random[./]', ['', '-lboost_random']],
\ ['^boost/regex[./]', ['', '-lboost_regex']],
\ ['^boost/serialization[./]', ['', '-lboost_serialization']],
\ ['^boost/signals[./]', ['', '-lboost_signals']],
\ ['^boost/system[./]', ['', '-lboost_system']],
\ ['^boost/thread[./]', ['', '-lboost_thread']],
\ ['^boost/timer[./]', ['', '-lboost_timer']],
\ ['^boost/wave[./]', ['', '-lboost_wave']],
\]

" thread
let s:flags += [
\ ['^thread$', ['', '-lpthread']],
\]

" fltk
if has('win32') || has('win64')
  let s:flags += [
  \ ['^fltk2[./]', ['', '-lfltk2 -lfltk2_images -lgdi32 -luser32 -luuid -lole32 -lcomdlg32 -lcomctl32 -lws2_32 -liphlpapi -lpsapi']],
  \ ['^fltk3[./]', ['', '-lfltk3 -lfltk3images -lgdi32 -luser32 -luuid -lole32 -lcomdlg32 -lcomctl32 -lws2_32 -liphlpapi -lpsapi']],
  \]
else
  let s:flags += [
  \ ['^fltk2[./]', ['', '-lfltk2 -lfltk2_images']],
  \ ['^fltk3[./]', ['', '-lfltk3 -lfltk3images']],
  \]
endif

function! quickrunex#lang#cpp#apply(session, context)
  call quickrunex#lang#c#apply(a:session, a:context)
endfunction

function! quickrunex#lang#cpp#get_flags()
  return quickrunex#lang#c#get_flags() + s:flags
endfunction
