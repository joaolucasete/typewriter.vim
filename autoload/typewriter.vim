let s:typewriter_enabled = v:false
let s:sound_dir = expand('<sfile>:p:h') .. '/../sounds'

let s:playing_clicks = {}

let s:clicks = [
      \   s:sound_dir .. '/click1.wav',
      \   s:sound_dir .. '/click2.wav',
      \   s:sound_dir .. '/click3.wav',
      \ ]
let s:carriage = s:sound_dir .. '/carriage1.wav'
let s:ding     = s:sound_dir .. '/ding1.wav'
let s:mpv_path = substitute(system('which mpv'), '\n', '', '') 

function! typewriter#Enable() abort
  call s:CheckRequirements()

  let s:typewriter_enabled = v:true

  augroup Typewriter
    autocmd!
    autocmd TextChangedI,TextChangedP * call s:Click()
    autocmd InsertEnter * call s:PlayFile(s:carriage)
    autocmd InsertLeave * call s:PlayFile(s:ding)
  augroup END
endfunction

function! typewriter#Disable() abort
  let s:typewriter_enabled = v:false

  augroup Typewriter
    autocmd!
  augroup END
endfunction

function! typewriter#Toggle() abort
  if s:typewriter_enabled
    call typewriter#Disable()
  else
    call typewriter#Enable()
  endif
endfunction

function! s:Click() abort
  if g:typewriter_throttle > 0 && len(keys(s:playing_clicks)) >= g:typewriter_throttle
    return
  endif

  let sound_file = s:clicks[rand() % len(s:clicks)]
  call s:PlayFile(sound_file)
endfunction

function! s:PlayFile(sound_file) abort
  let FinishedCallback = {id, _ -> remove(s:playing_clicks, id)}
  if has('sound')
    let sound_id = sound_playfile(a:sound_file, {'on_finished': FinishedCallback})
  else
    let cmd = [s:mpv_path, a:sound_file]
    let sound_id = jobstart(cmd, {'detach': v:true, 'on_exit': FinishedCallback})
  endif
  let s:playing_clicks[sound_id] = 1
endfunction

function! s:CheckRequirements() abort
  if !has('sound') && !has('nvim')
    echo "Typewriter.vim requires a Vim compiled with +sound"
    return
  elseif has('nvim') && s:mpv_path == ''
    echo "Typewriter.vim running in nvim requires mpv installed in your path"
    return
  endif
endfunction
