function! quickrunex#lang#go#apply(session, context)
  let [n, l] = [1, line('$')]
  let pkgs = []
  while n < l
    let linestr = getline(n)
    if linestr =~# '^import\s\+('
      while n <= l
        let n = n + 1
        let linestr = getline(n)
        if linestr == ')'
          break
        endif
        let m = matchstr(linestr, '^.*"\zs[^"]\+\ze"')
        if len(m) == 0
          continue
        endif
        call add(pkgs, m)
      endwhile
      break
    elseif linestr =~# '^import '
      let m = matchstr(linestr, '^.*"\zs[^"]\+\ze"')
      if len(m) == 0
        continue
      endif
      call add(pkgs, m)
    endif
    let n += 1
  endwhile
  if !exists('b:quickrunex')
    let b:quickrunex = {"pkgs": {}}
  endif
  for pkg in pkgs
    if !has_key(config['pkgs'], pkg)
      call system(printf("go get %s", pkg))
      let b:quickrunex['pkgs'][pkg] = 1
    endif
  endfor
endfunction
