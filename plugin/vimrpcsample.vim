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

call s:init()
