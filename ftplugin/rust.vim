let b:toc_nesting='nesting'
let b:toc_pattern='\v^\s*(pub\s+)?(impl|fn)(\<[^>]*\>)?\s+\w+'
function! s:toc_parse_match(match)
    return { 'name': substitute(
                    \ substitute(a:match.text, '\v^\s*(pub\s+)?fn(<[^>]*>)?\s+(\w+).*', '\3', ''),
                    \ '\v^\s*impl(\<[^>]*\>)?\s+((\w|:)+(\<[^>]*\>)?(\s+for\s+\w+(\<[^>]*\>)?)?).*',
                    \ '\2', '' ),
                \ 'region': TocCurlyBracketEnd(a:match.lnum)
                \ }
endfunction
let b:toc_parse_match = function("s:toc_parse_match")
