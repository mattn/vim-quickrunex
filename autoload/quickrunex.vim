function! quickrunex#merge_flags(flags, lang)
  let flags = a:flags
  let config = get(g:, 'quickrunex_config')
  if type(config) == 4 && has_key(config, a:lang)
    let user_flags = config[a:lang]
	if type(user_flags) == 3
      let flags = user_flags + flags
    elseif type(user_flags) == 2
      call extend(flags, call(user_flags, flags))
    endif
  endif
  return flags
endfunction
