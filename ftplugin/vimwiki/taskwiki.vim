" Check VIM version
if version < 704
  echoerr "Taskwiki requires at least Vim 7.4. Please upgrade your environment."
  finish
endif

" Python version detection.
if has("nvim")
  let g:taskwiki_py='py3 '
  let g:taskwiki_pyfile='py3file '
elseif has("python3") && ! exists("g:taskwiki_use_python2")
  let g:taskwiki_py='py3 '
  let g:taskwiki_pyfile='py3file '
elseif has("python")
  let g:taskwiki_py='py '
  let g:taskwiki_pyfile='pyfile '
else
  echoerr "Taskwiki requires Vim compiled with the Python support."
  finish
endif

" Disable taskwiki if taskwiki_disable variable set
if exists("g:taskwiki_disable")
  finish
endif

" Determine the plugin path
let s:plugin_path = escape(expand('<sfile>:p:h:h:h'), '\')

" Execute the main body of taskwiki source
execute g:taskwiki_pyfile . s:plugin_path . '/taskwiki/main.py'

augroup taskwiki
    autocmd!
    " Update to TW upon saving
    execute "autocmd BufWrite *.".expand('%:e')." TaskWikiBufferSave"
    " Save and load the view to preserve folding, if desired
    if !exists('g:taskwiki_dont_preserve_folds')
      execute "autocmd BufWinLeave *.".expand('%:e')." mkview"
      execute "autocmd BufWinEnter *.".expand('%:e')." silent! loadview"
      execute "autocmd BufWinEnter *.".expand('%:e')." silent! doautocmd SessionLoadPost *.".expand('%:e')
    endif
    execute "autocmd BufEnter *.".expand('%:e')." :" . g:taskwiki_py . "cache.load_current().reset()"
augroup END

" Global update commands
execute "command! -nargs=* TaskWikiBufferSave :"      . g:taskwiki_py . "WholeBuffer.update_to_tw()"
execute "command! -nargs=* TaskWikiBufferLoad :"      . g:taskwiki_py . "WholeBuffer.update_from_tw()"

" Split reports commands
execute "command! -nargs=* TaskWikiProjects :"        . g:taskwiki_py . "SplitProjects(<q-args>).execute()"
execute "command! -nargs=* TaskWikiProjectsSummary :" . g:taskwiki_py . "SplitSummary(<q-args>).execute()"
execute "command! -nargs=* TaskWikiBurndownDaily :"   . g:taskwiki_py . "SplitBurndownDaily(<q-args>).execute()"
execute "command! -nargs=* TaskWikiBurndownMonthly :" . g:taskwiki_py . "SplitBurndownMonthly(<q-args>).execute()"
execute "command! -nargs=* TaskWikiBurndownWeekly :"  . g:taskwiki_py . "SplitBurndownWeekly(<q-args>).execute()"
execute "command! -nargs=* TaskWikiCalendar :"        . g:taskwiki_py . "SplitCalendar(<q-args>).execute()"
execute "command! -nargs=* TaskWikiGhistoryAnnual :"  . g:taskwiki_py . "SplitGhistoryAnnual(<q-args>).execute()"
execute "command! -nargs=* TaskWikiGhistoryMonthly :" . g:taskwiki_py . "SplitGhistoryMonthly(<q-args>).execute()"
execute "command! -nargs=* TaskWikiHistoryAnnual :"   . g:taskwiki_py . "SplitHistoryAnnual(<q-args>).execute()"
execute "command! -nargs=* TaskWikiHistoryMonthly :"  . g:taskwiki_py . "SplitHistoryMonthly(<q-args>).execute()"
execute "command! -nargs=* TaskWikiStats :"           . g:taskwiki_py . "SplitStats(<q-args>).execute()"
execute "command! -nargs=* TaskWikiTags :"            . g:taskwiki_py . "SplitTags(<q-args>).execute()"

" Commands that operate on tasks in the buffer
execute "command! -range TaskWikiInfo :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().info()"
execute "command! -range TaskWikiEdit :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().edit()"
execute "command! -range TaskWikiLink :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().link()"
execute "command! -range TaskWikiGrid :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().grid()"
execute "command! -range TaskWikiDelete :<line1>,<line2>" . g:taskwiki_py . "SelectedTasks().delete()"
execute "command! -range TaskWikiStart :<line1>,<line2>"  . g:taskwiki_py . "SelectedTasks().start()"
execute "command! -range TaskWikiStop :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().stop()"
execute "command! -range TaskWikiDone :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().done()"
execute "command! -range TaskWikiRedo :<line1>,<line2>"   . g:taskwiki_py . "SelectedTasks().redo()"

execute "command! -range -nargs=* TaskWikiSort :<line1>,<line2>"     . g:taskwiki_py . "SelectedTasks().sort(<q-args>)"
execute "command! -range -nargs=* TaskWikiMod :<line1>,<line2>"      . g:taskwiki_py . "SelectedTasks().modify(<q-args>)"
execute "command! -range -nargs=* TaskWikiAnnotate :<line1>,<line2>" . g:taskwiki_py . "SelectedTasks().annotate(<q-args>)"

" Interactive commands
execute "command! -range TaskWikiChooseProject :<line1>,<line2>"     . g:taskwiki_py . "ChooseSplitProjects('global').execute()"
execute "command! -range TaskWikiChooseTag :<line1>,<line2>"         . g:taskwiki_py . "ChooseSplitTags('global').execute()"

" Meta commands
execute "command! TaskWikiInspect :" . g:taskwiki_py . "Meta().inspect_viewport()"

" Disable <CR> as VimwikiFollowLink
if !hasmapto('<Plug>VimwikiFollowLink')
  nmap <Plug>NoVimwikiFollowLink <Plug>VimwikiFollowLink
endif

execute "nnoremap <silent><buffer> <CR> :" . g:taskwiki_py . "Mappings.task_info_or_vimwiki_follow_link()<CR>"

" Leader-related mappings. Mostly <Leader>p + <first letter of the action>
nmap <silent><buffer> <Leader>pa :TaskWikiAnnotate<CR>
nmap <silent><buffer> <Leader>pbd :TaskWikiBurndownDaily<CR>
nmap <silent><buffer> <Leader>pbw :TaskWikiBurndownWeekly<CR>
nmap <silent><buffer> <Leader>pbm :TaskWikiBurndownMonthly<CR>
nmap <silent><buffer> <Leader>pcp :TaskWikiChooseProject<CR>
nmap <silent><buffer> <Leader>pct :TaskWikiChooseTag<CR>
nmap <silent><buffer> <Leader>pC :TaskWikiCalendar<CR>
nmap <silent><buffer> <Leader>pd :TaskWikiDone<CR>
nmap <silent><buffer> <Leader>pD :TaskWikiDelete<CR>
nmap <silent><buffer> <Leader>pe :TaskWikiEdit<CR>
nmap <silent><buffer> <Leader>pg :TaskWikiGrid<CR>
nmap <silent><buffer> <Leader>pGm :TaskWikiGhistoryMonthly<CR>
nmap <silent><buffer> <Leader>pGa :TaskWikiGhistoryAnnual<CR>
nmap <silent><buffer> <Leader>phm :TaskWikiHistoryMonthly<CR>
nmap <silent><buffer> <Leader>pha :TaskWikiHistoryAnnual<CR>
nmap <silent><buffer> <Leader>pi :TaskWikiInfo<CR>
nmap <silent><buffer> <Leader>pl :TaskWikiLink<CR>
nmap <silent><buffer> <Leader>pm :TaskWikiMod<CR>
nmap <silent><buffer> <Leader>pp :TaskWikiProjects<CR>
nmap <silent><buffer> <Leader>ps :TaskWikiProjectsSummary<CR>
nmap <silent><buffer> <Leader>pS :TaskWikiStats<CR>
nmap <silent><buffer> <Leader>pt :TaskWikiTags<CR>
nmap <silent><buffer> <Leader>p. :TaskWikiRedo<CR>
nmap <silent><buffer> <Leader>p+ :TaskWikiStart<CR>
nmap <silent><buffer> <Leader>p- :TaskWikiStop<CR>

" Mappings for visual mode.
vmap <silent><buffer> <Leader>pa :TaskWikiAnnotate<CR>
vmap <silent><buffer> <Leader>pcp :TaskWikiChooseProject<CR>
vmap <silent><buffer> <Leader>pct :TaskWikiChooseTag<CR>
vmap <silent><buffer> <Leader>pd :TaskWikiDone<CR>
vmap <silent><buffer> <Leader>pD :TaskWikiDelete<CR>
vmap <silent><buffer> <Leader>pe :TaskWikiEdit<CR>
vmap <silent><buffer> <Leader>pg :TaskWikiGrid<CR>
vmap <silent><buffer> <Leader>pi :TaskWikiInfo<CR>
vmap <silent><buffer> <Leader>pl :TaskWikiLink<CR>
vmap <silent><buffer> <Leader>pm :TaskWikiMod<CR>
vmap <silent><buffer> <Leader>p. :TaskWikiRedo<CR>
vmap <silent><buffer> <Leader>p+ :TaskWikiStart<CR>
vmap <silent><buffer> <Leader>p- :TaskWikiStop<CR>
