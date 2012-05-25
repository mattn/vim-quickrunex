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
  for pkg in pkgs
    call system(printf("go get %s", pkg))
  endfor
endfunction
