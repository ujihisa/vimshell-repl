let s:TRUE = 1
let s:FALSE = 0
let s:TABLE = {
      \ 'ruby': 'irb',
      \ 'haskell': 'ghci',
      \ 'javascript': 'node',
      \ }

function! repl#new()
  let r = {}
  for l:lang in keys(s:TABLE)
    if &filetype ==# l:lang
      let r.command = s:TABLE[l:lang]
      break
    endif
  endfor
  let r.command = get(r, 'command', '')
  return r
endfunction

function! repl#already_p(r)
  for i in repl#get_buffer_list()
    if bufname(i) =~# ('^iexe-' . a:r.command)
      return s:TRUE
    endif
  endfor
  return s:FALSE
endfunction

function! repl#move_to_existing_repl(r)
  " assuming it's already_p
  for i in repl#get_buffer_list()
    if bufname(i) =~# ('^iexe-' . a:r.command)
      if bufwinnr(i) > 0
        execute i . 'wincmd w'
      else
        execute i . 'sbuffer'
      endif
      return
    endif
  endfor
  echoerr 'assumption error'
endfunction

let s:buffer_list = {}
function! repl#get_buffer_list() " from unite buffer
  " Make buffer list.
  let l:list = []
  let l:bufnr = 1
  while l:bufnr <= bufnr('$')
    if buflisted(l:bufnr) && l:bufnr != bufnr('%')
      if has_key(s:buffer_list, l:bufnr)
        call add(l:list, s:buffer_list[l:bufnr])
      else
        call add(l:list, l:bufnr)
      endif
    endif
    let l:bufnr += 1
  endwhile

  if buflisted(bufnr('%'))
    " Add current buffer.
    if has_key(s:buffer_list, bufnr('%'))
      call add(l:list, s:buffer_list[bufnr('%')])
    else
      call add(l:list, bufnr('%'))
    endif
  endif

  return l:list
endfunction

function! repl#open()
  let r = repl#new()
  if repl#already_p(r)
    call repl#move_to_existing_repl(r)
  else
    if r.command != ''
      execute 'VimShellInteractive' r.command
    else
      echo 'No interpreter found'
    endif
  end
endfunction
