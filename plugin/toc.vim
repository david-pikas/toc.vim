" toc.vim - View the table of contents of a document or code file
" Maintainer:   David Pikas <david@pikas.se>
" Version:      0.0

command TocDrawer call TocOpenDrawer()

function! TocOpenDrawer()
    call TocPopulateLocl()
    augroup toc_update_cursor
        autocmd!
        autocmd CursorMoved <buffer> call TocUpdateLocList()
    augroup END
    execute 'vert lopen'
    call win_execute(getloclist(0, {'winid': 1}).winid, 'let b:loc_lines = getline(1,"$")')
    let widest_column = max(b:loc_lines->map({_,v -> strlen(v)}))
    let split_width = widest_column + &numberwidth + 1 " + 1 for the window seperator
    execute 'vert resize ' . split_width
endfunction

function! TocPopulateLocl()
    " if (!exists(b:toc_nesting) || !exists(b:toc_pattern))
    "     return
    " endif
    let b:toc_matches = s:build_loc_entries(s:search_all(b:toc_pattern))
    let s:loc_idx = 1
    call setloclist(
        \ winnr(),
        \ b:toc_matches,
        \ 'r'
        \ )

endfunction

function! TocUpdateLocList()
    let old_loc_idx = s:loc_idx
    let curr_line = line('.') + 1 " line('.') is 0-indexed
    let idx = 0
    for entry in b:toc_matches
        if curr_line > entry.lnum
            let idx += 1
        else
            break
        endif
    endfor
    let s:loc_idx = idx
    if old_loc_idx != s:loc_idx
        call setloclist(0, [], 'a', {'idx': s:loc_idx })
    endif
endfunction


function! s:build_loc_entries(matches)
    let loc_entries = []
    let indents = []
    let regions = []
    for matched in a:matches
        let parse_arg = { 'lnum': matched[0],
                    \ 'text': matched[1],
                    \ }
        let parse_result = b:toc_parse_match(parse_arg)
        if type(parse_result) != type({})
            continue
        endif
        if b:toc_nesting ==# 'indent'
            let indent_level = 0
            let current_indent = strlen( substitute(
                        \ substitute(parse_arg.text, '\v^(\s*).*$', '\1', ''),
                        \ '\t',
                        \ repeat(' ', &tabstop),
                        \ 'g'
                        \ ) )
            if len(indents) == 0 || current_indent > indents[len(indents)-1] 
                call add(indents, current_indent)
                let indent_level = len(indents)
            else
                let idx = 0
                let skip_match = 0
                for indent in indents
                    let idx += 1
                    if current_indent == indent
                        let indents = indents[0:idx]
                        let indent_level = idx
                        break
                    elseif current_indent < indent
                        " malformed indent, skip this item
                        let skip_match = 1
                        break
                    endif
                endfor
                if skip_match == 1
                    " continue
                endif
            endif
            let parse_result.level = indent_level
        elseif b:toc_nesting ==# 'nesting'
            let idx = 0
            for regio in regions
                if parse_arg.lnum > regio
                    if idx == 0
                        let regions = []
                    else 
                        let regions = regions[0:idx-1]
                    endif
                    break
                endif
                let idx += 1
            endfor
            call add(regions, parse_result.region)
            let level = len(regions)
            let parse_result.level = level
        endif
        call add(loc_entries, { 'bufnr': bufnr("%"),
                    \ 'filename': expand("%"),
                    \ 'module': ' ',
                    \ 'lnum': matched[0],
                    \ 'text': s:display_entry_default(parse_result)
                    \ })
    endfor
    return loc_entries
endfunction

function! s:display_entry(parse_result)
    if (exists(b:toc_display_entry))
        return b:toc_display_entry(a:parse_result)
    else
        return s:display_entry_default(a:parse_result)
    endif
endfunction

function! s:display_entry_default(parse_result)
    return repeat('-', a:parse_result.level - 1) . a:parse_result.name
endfunction

function! s:search_all(pattern)
    let old_cursor = getcurpos()[1:-1]
    call cursor(1, 0)
    let lines = []
    while search(a:pattern, 'W') != 0
        if get(b:, 'toc_multiline', 0)
            let firstline=line('.')
            call search(a:pattern, 'eW') 
            let line=join(getline(firstline,'.'), "\n")
        else
            let line=getline('.')
        endif
        call add(lines, [line('.'), line])
    endwhile
    call cursor(old_cursor)
    return lines
endfunction

function! SearchAll(pattern)
    return s:search_all(a:pattern)
endfunction

function! TocCurlyBracketEnd(lnum)
    let old_cursor = getcurpos()[1:-1]
    call cursor(a:lnum, 0)
    call search('{', 'W')
    let regio = searchpair('{', '', '}', 'W',
                \ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"' )
    call cursor(old_cursor)
    return regio
endfunction
