let s:TABLE = {
      \ 'ruby': ['irb', '--simple-prompt'],
      \ 'haskell': ['ghci'],
      \ 'javascript': ['node'],
      \ }

function! repl#new()
  let r = {}
  let r.commands = get(s:TABLE, &filetype, [])
  let r.lookup_the_repl = function('s:lookup_the_repl')
  return r
endfunction

function! s:lookup_the_repl() dict
  for i in repl#get_buffer_list()
    if bufname(i) =~# ('^iexe-' . self.commands[0])
      return {'just': i}
    endif
  endfor
  return {'nothing': 0}
endfunction

function! repl#move_to_existing_repl(i)
  if bufwinnr(a:i) > 0
    execute a:i . 'wincmd w'
  else
    execute a:i . 'sbuffer'
  endif
  startinsert!
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
  let maybe = r.lookup_the_repl()
  if exists('maybe.just')
    call repl#move_to_existing_repl(maybe.just)
  else
    if r.commands != []
      execute 'VimShellInteractive' join(r.commands, ' ')
    else
      echo 'No interpreter found'
    endif
  end
endfunction
