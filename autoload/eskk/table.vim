" vim:foldmethod=marker:fen:
scriptencoding utf-8

" See 'plugin/eskk.vim' about the license.

" Load once {{{
if exists('s:loaded')
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}
runtime! plugin/eskk.vim



" Variables {{{
let s:table_defs = {}

let s:MAP_TO_INDEX = 0
let s:REST_INDEX = 1
lockvar s:MAP_TO_INDEX
lockvar s:REST_INDEX
" }}}


" Functions {{{

" Primitive table functions {{{

" NOTE: `s:table_defs` Structure is:
" let s:table_defs['table_name'] = {
"   'base': {...},
"   'derived': [{'method': 'add', 'data': {...}}, ...],
" }


function! s:get_table(table_name, ...) "{{{
    if has_key(s:table_defs, a:table_name)
        return s:table_defs[a:table_name].base
    endif

    " Lazy loading.
    call s:set_table(a:table_name, eskk#table#{a:table_name}#load())
    call eskk#util#logf("table '%s' has been loaded.", a:table_name)
    return s:table_defs[a:table_name].base
endfunction "}}}

function! s:has_table(table_name) "{{{
    return has_key(s:table_defs, a:table_name)
endfunction "}}}

function! s:set_table(table_name, base_dict, ...) "{{{
    if s:has_table(a:table_name)
        " Do not allow override table.
        let msg = printf("'%s' has been already registered.", a:table_name)
        throw eskk#internal_error(['eskk', 'table'], msg)
    endif

    let s:table_defs[a:table_name] = {}
    let def = s:table_defs[a:table_name]

    let def.base = a:base_dict
    if a:0
        " No "derived" key if `def` is base table object.
        let def.derived = a:1
    endif
endfunction "}}}

" }}}


" Autoload functions for writing table. {{{

function! eskk#table#register_table(...) "{{{
    call call('s:set_table', a:000)
endfunction "}}}

" }}}


" Autoload functions {{{

function! eskk#table#has_candidates(...) "{{{
    return !empty(call('eskk#table#get_candidates', a:000))
endfunction "}}}

function! eskk#table#get_candidates(table_name, str_buf) "{{{
    if empty(a:str_buf)
        throw eskk#internal_error(['eskk', 'table'], "a:str_buf is empty.")
    endif

    let no_table = {}
    let def = s:get_table(a:table_name, no_table)
    if def is no_table
        return no_table
    else
        return filter(
        \   keys(def),
        \   'stridx(v:val, a:str_buf) == 0'
        \)
    endif
endfunction "}}}


function! eskk#table#has_table(name) "{{{
    return s:get_table(a:name, -1) !=# -1
endfunction "}}}

function! eskk#table#has_map(table_name, lhs) "{{{
    return has_key(s:get_table(a:table_name), a:lhs)
endfunction "}}}


function! eskk#table#get_map_to(table_name, lhs, ...) "{{{
    let def = s:get_table(a:table_name)
    if empty(def) || !eskk#table#has_map(a:table_name, a:lhs)
        if a:0 == 0
            throw eskk#internal_error(['eskk', 'table'])
        else
            return a:1
        endif
    endif
    return def[a:lhs][s:MAP_TO_INDEX]
endfunction "}}}


function! eskk#table#has_rest(table_name, lhs) "{{{
    return eskk#util#has_key_f(s:get_table(a:table_name), [a:lhs, 'rest'])
endfunction "}}}

function! eskk#table#get_rest(table_name, lhs, ...) "{{{
    let def = s:get_table(a:table_name)
    if empty(def) || !eskk#table#has_rest(a:table_name, a:lhs)
        if a:0 == 0
            throw eskk#internal_error(['eskk', 'table'])
        else
            return a:1
        endif
    endif
    return def[a:lhs][s:REST_INDEX]
endfunction "}}}


function! eskk#table#get_definition(table_name) "{{{
    return s:get_table(a:table_name)
endfunction "}}}

function! eskk#table#get_table(table_name) "{{{
    let varname = 's:lazy_table_' . a:table_name
    if exists(varname)
        return {varname}
    else
        let {varname} = eskk#table#new(a:table_name)
        return {varname}
    endif
endfunction "}}}

" }}}


" OO interface {{{
let s:table_obj = {}

function! eskk#table#new(table_name) "{{{
    let obj = deepcopy(s:table_obj)
    let obj.table_name = a:table_name

    return obj
endfunction "}}}


" I need meta programming in Vim script!!

function! s:table_obj.has_candidates(...) dict "{{{
    return call('eskk#table#has_candidates', [self.table_name] + a:000)
endfunction "}}}

function! s:table_obj.get_candidates(...) dict "{{{
    return call('eskk#table#get_candidates', [self.table_name] + a:000)
endfunction "}}}

function! s:table_obj.has_map(...) dict "{{{
    return call('eskk#table#has_map', [self.table_name] + a:000)
endfunction "}}}

function! s:table_obj.get_map_to(...) dict "{{{
    return call('eskk#table#get_map_to', [self.table_name] + a:000)
endfunction "}}}

function! s:table_obj.has_rest(...) dict "{{{
    return call('eskk#table#has_rest', [self.table_name] + a:000)
endfunction "}}}

function! s:table_obj.get_rest(...) dict "{{{
    return call('eskk#table#get_rest', [self.table_name] + a:000)
endfunction "}}}


lockvar s:table_obj
" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
