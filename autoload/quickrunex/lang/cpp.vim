" boost
let s:flags = [
\ ['^boost/chrono[./]', ['', '-lboost_chrono -lboost_system']],
\ ['^boost/coroutine[./]', ['-lboost_context', '-lboost_system']],
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
\ ['^boost/thread[./]', ['', '-lboost_system -lboost_thread']],
\ ['^boost/timer[./]', ['', '-lboost_timer']],
\ ['^boost/wave[./]', ['', '-lboost_wave']],
\]

" boost/asio
if has('win32') || has('win64')
let s:flags += [
\ ['^boost/asio[./]', ['', '-lboost_system -lmswsock -lws2_32']],
\]
endif

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

" qt
let s:qtroot = len($QT_ROOT) > 0 ? $QT_ROOT : $QTDIR
if stridx(tolower(s:qtroot), 'qt4') != -1
  let s:qtinc = '-I'.substitute(s:qtroot, '\\', '/', 'g').'/include'
  let s:qtlib = '-L'.substitute(s:qtroot, '\\', '/', 'g').'/lib'
  let s:flags += [
  \ ['^QtCore/', [s:qtinc, s:qtlib.' -lQtCore4']],
  \ ['^QtGui/', [s:qtinc, s:qtlib.' -lQtGui4']],
  \ ['^QtNetwork/', [s:qtinc, s:qtlib.' -lQtNetwork4']],
  \]
elseif stridx(tolower(s:qtroot), 'qt5') != -1
  let s:qtinc = '-I'.substitute(s:qtroot, '\\', '/', 'g').'/include'
  let s:qtlib = '-L'.substitute(s:qtroot, '\\', '/', 'g').'/lib'
  let s:flags += [
  \ ['^QtCore/', [s:qtinc, s:qtlib.' -static-libgcc -static-libstdc++ -lQt5Core']],
  \ ['^QtGui/', [s:qtinc, s:qtlib.' -static-libgcc -static-libstdc++ -lQt5Gui -lQt5Core']],
  \ ['^QtNetwork/', [s:qtinc, s:qtlib.' -static-libgcc -static-libstdc++ -lQt5Network -lQt5Core']],
  \ ['^QtWidgets/', [s:qtinc, s:qtlib.' -static-libgcc -static-libstdc++ -lQt5Widgets -lQt5Core']],
  \]
endif

function! quickrunex#lang#cpp#apply(session, context)
  call quickrunex#lang#c#apply(a:session, a:context)
endfunction

function! quickrunex#lang#cpp#get_flags()
  return quickrunex#merge_flags(quickrunex#lang#c#get_flags() + s:flags, "cpp")
endfunction
