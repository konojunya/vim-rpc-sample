" initialize
if !exists("s:vimrpcsampleJobId")
  let s:vimrpcsampleJobId = 0
endif

let s:target = "/Users/konojunya/.ghq/src/github.com/konojunya/vim-rpc-sample/target/debug/vim-rpc-sample"

function! s:init()
  let id = s:initRpc()

  if 0 == id
    echoerr 'vimrpcsample: cannnot start rpc process'
  elseif -1 == id
    echoerr 'vimrpcsampleJobId: rpc process is not executable'
  else
    let s:vimrpcsampleJobId = id

    command! -nargs=+ VRSAdd :call s:add(<f-args>)
    command! -nargs=1 VRSRead :call s:read(<f-args>)

  endif
endfunction

function! s:initRpc()
  if s:vimrpcsampleJobId == 0
    let jobid = jobstart([s:target], { 'rpc': v:true })
    return jobid
  else
    return s:vimrpcsampleJobId
  endif
endfunction

function! s:add(...)
  let s:p = get(a:, 1, 0)
  let s:q = get(a:, 2, 0)

  call rpcnotify(s:vimrpcsampleJobId, "add", str2nr(s:p), str2nr(s:q))
endfunction

function! s:read(args)
  augroup vimrpcsample-new-buffer
    autocmd!
    autocmd BufWriteCmd new-buffer call s:on_save()
  augroup END

  let s:parent_bufnr = bufnr('%')

  new
  call setline(1, a:args)

  file new-buffer
  set nomodified
  setlocal buftype=acwrite
  setlocal filetype=md
  setlocal noswapfile
endfunction

function! s:find_buf(bufnr) abort
  if !exists('*win_findbuf')
    " win_findbuf() is available since patch 7.4.1558
    return []
  endif

  return win_findbuf(a:bufnr)
endfunction

function! s:get_winid() abort
  if !exists('*win_getid')
    " win_getid() is available since patch 7.4.1557
    return 0
  endif

  return win_getid()
endfunction

function! s:gotoid(expr) abort
  if !exists('*win_gotoid')
    " win_gotoid() is available since patch 7.4.1557
    return 0
  endif

  return win_gotoid(a:expr)
endfunction

function! s:on_save()
  let lines = getline(1, line("$"))
  set nomodified

  echo lines

  let win_ids = s:find_buf(s:parent_bufnr)
  if empty(win_ids)
    return
  endif

  let win_id = s:get_winid()
  if s:gotoid(win_ids[0])
    call s:gotoid(win_id)
  endif

  " call rpcnotify(s:vimrpcsampleJobId, 'save', lines)
endfunction

call s:init()
