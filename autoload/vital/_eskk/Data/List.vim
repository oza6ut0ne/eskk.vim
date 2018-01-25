" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not mofidify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_eskk#Data#List#import() abort', printf("return map({'combinations': '', 'and': '', 'sort_by': '', 'foldr1': '', 'sort': '', 'flatten': '', 'has_index': '', 'find_indices': '', 'any': '', 'unshift': '', 'span': '', 'pop': '', 'binary_search': '', 'uniq_by': '', 'or': '', 'all': '', 'zip': '', 'find_last_index': '', 'find': '', 'partition': '', 'shift': '', 'permutations': '', 'break': '', 'max_by': '', 'foldl': '', 'foldr': '', 'find_index': '', 'drop_while': '', 'group_by': '', 'take_while': '', 'conj': '', 'push': '', 'char_range': '', 'cons': '', 'foldl1': '', 'intersect': '', 'concat': '', 'map_accum': '', 'clear': '', 'has_common_items': '', 'product': '', 'zip_fill': '', 'uniq': '', 'has': '', 'min_by': '', 'with_index': ''}, \"vital#_eskk#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
" Utilities for list.

let s:save_cpo = &cpo
set cpo&vim

function! s:pop(list) abort
  return remove(a:list, -1)
endfunction

function! s:push(list, val) abort
  call add(a:list, a:val)
  return a:list
endfunction

function! s:shift(list) abort
  return remove(a:list, 0)
endfunction

function! s:unshift(list, val) abort
  return insert(a:list, a:val)
endfunction

function! s:cons(x, xs) abort
  return [a:x] + a:xs
endfunction

function! s:conj(xs, x) abort
  return a:xs + [a:x]
endfunction

" Removes duplicates from a list.
function! s:uniq(list) abort
  return s:uniq_by(a:list, 'v:val')
endfunction

" Removes duplicates from a list.
function! s:uniq_by(list, f) abort
  let list = map(copy(a:list), printf('[v:val, %s]', a:f))
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(list[i][1])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return map(list, 'v:val[0]')
endfunction

function! s:clear(list) abort
  if !empty(a:list)
    unlet! a:list[0 : len(a:list) - 1]
  endif
  return a:list
endfunction

" Concatenates a list of lists.
" XXX: Should we verify the input?
function! s:concat(list) abort
  let memo = []
  for Value in a:list
    let memo += Value
  endfor
  return memo
endfunction

" Take each elements from lists to a new list.
function! s:flatten(list, ...) abort
  let limit = a:0 > 0 ? a:1 : -1
  let memo = []
  if limit == 0
    return a:list
  endif
  let limit -= 1
  for Value in a:list
    let memo +=
          \ type(Value) == type([]) ?
          \   s:flatten(Value, limit) :
          \   [Value]
    unlet! Value
  endfor
  return memo
endfunction

" Sorts a list with expression to compare each two values.
" a:a and a:b can be used in {expr}.
function! s:sort(list, expr) abort
  if type(a:expr) == type(function('function'))
    return sort(a:list, a:expr)
  endif
  let s:expr = a:expr
  return sort(a:list, 's:_compare')
endfunction

function! s:_compare(a, b) abort
  return eval(s:expr)
endfunction

" Sorts a list using a set of keys generated by mapping the values in the list
" through the given expr.
" v:val is used in {expr}
function! s:sort_by(list, expr) abort
  let pairs = map(a:list, printf('[v:val, %s]', a:expr))
  return map(s:sort(pairs,
  \      'a:a[1] ==# a:b[1] ? 0 : a:a[1] ># a:b[1] ? 1 : -1'), 'v:val[0]')
endfunction

" Returns a maximum value in {list} through given {expr}.
" Returns 0 if {list} is empty.
" v:val is used in {expr}
function! s:max_by(list, expr) abort
  if empty(a:list)
    return 0
  endif
  let list = map(copy(a:list), a:expr)
  return a:list[index(list, max(list))]
endfunction

" Returns a minimum value in {list} through given {expr}.
" Returns 0 if {list} is empty.
" v:val is used in {expr}
" FIXME: -0x80000000 == 0x80000000
function! s:min_by(list, expr) abort
  return s:max_by(a:list, '-(' . a:expr . ')')
endfunction

" Returns List of character sequence between [a:from, a:to]
" e.g.: s:char_range('a', 'c') returns ['a', 'b', 'c']
function! s:char_range(from, to) abort
  return map(
  \   range(char2nr(a:from), char2nr(a:to)),
  \   'nr2char(v:val)'
  \)
endfunction

" Returns true if a:list has a:value.
" Returns false otherwise.
function! s:has(list, value) abort
  return index(a:list, a:value) isnot -1
endfunction

" Returns true if a:list[a:index] exists.
" Returns false otherwise.
" NOTE: Returns false when a:index is negative number.
function! s:has_index(list, index) abort
  " Return true when negative index?
  " let index = a:index >= 0 ? a:index : len(a:list) + a:index
  return 0 <= a:index && a:index < len(a:list)
endfunction

" similar to Haskell's Data.List.span
function! s:span(f, xs) abort
  let border = len(a:xs)
  for i in range(len(a:xs))
    if !eval(substitute(a:f, 'v:val', string(a:xs[i]), 'g'))
      let border = i
      break
    endif
  endfor
  return border == 0 ? [[], copy(a:xs)] : [a:xs[: border - 1], a:xs[border :]]
endfunction

" similar to Haskell's Data.List.break
function! s:break(f, xs) abort
  return s:span(printf('!(%s)', a:f), a:xs)
endfunction

" similar to Haskell's Data.List.takeWhile
function! s:take_while(f, xs) abort
  return s:span(a:f, a:xs)[0]
endfunction

" similar to Haskell's Data.List.dropWhile
function! s:drop_while(f, xs) abort
  return s:span(a:f, a:xs)[1]
endfunction

" similar to Haskell's Data.List.partition
function! s:partition(f, xs) abort
  return [filter(copy(a:xs), a:f), filter(copy(a:xs), '!(' . a:f . ')')]
endfunction

" similar to Haskell's Prelude.all
function! s:all(f, xs) abort
  return !s:any(printf('!(%s)', a:f), a:xs)
endfunction

" similar to Haskell's Prelude.any
function! s:any(f, xs) abort
  return !empty(filter(map(copy(a:xs), a:f), 'v:val'))
endfunction

" similar to Haskell's Prelude.and
function! s:and(xs) abort
  return s:all('v:val', a:xs)
endfunction

" similar to Haskell's Prelude.or
function! s:or(xs) abort
  return s:any('v:val', a:xs)
endfunction

function! s:map_accum(expr, xs, init) abort
  let memo = []
  let init = a:init
  for x in a:xs
    let expr = substitute(a:expr, 'v:memo', init, 'g')
    let expr = substitute(expr, 'v:val', x, 'g')
    let [tmp, init] = eval(expr)
    call add(memo, tmp)
  endfor
  return memo
endfunction

" similar to Haskell's Prelude.foldl
function! s:foldl(f, init, xs) abort
  let memo = a:init
  for x in a:xs
    let expr = substitute(a:f, 'v:val', string(x), 'g')
    let expr = substitute(expr, 'v:memo', string(memo), 'g')
    unlet memo
    let memo = eval(expr)
  endfor
  return memo
endfunction

" similar to Haskell's Prelude.foldl1
function! s:foldl1(f, xs) abort
  if len(a:xs) == 0
    throw 'vital: Data.List: foldl1'
  endif
  return s:foldl(a:f, a:xs[0], a:xs[1:])
endfunction

" similar to Haskell's Prelude.foldr
function! s:foldr(f, init, xs) abort
  return s:foldl(a:f, a:init, reverse(copy(a:xs)))
endfunction

" similar to Haskell's Prelude.fold11
function! s:foldr1(f, xs) abort
  if len(a:xs) == 0
    throw 'vital: Data.List: foldr1'
  endif
  return s:foldr(a:f, a:xs[-1], a:xs[0:-2])
endfunction

" similar to python's zip()
function! s:zip(...) abort
  return map(range(min(map(copy(a:000), 'len(v:val)'))), "map(copy(a:000), 'v:val['.v:val.']')")
endfunction

" similar to zip(), but goes until the longer one.
function! s:zip_fill(xs, ys, filler) abort
  if empty(a:xs) && empty(a:ys)
    return []
  elseif empty(a:ys)
    return s:cons([a:xs[0], a:filler], s:zip_fill(a:xs[1 :], [], a:filler))
  elseif empty(a:xs)
    return s:cons([a:filler, a:ys[0]], s:zip_fill([], a:ys[1 :], a:filler))
  else
    return s:cons([a:xs[0], a:ys[0]], s:zip_fill(a:xs[1 :], a:ys[1: ], a:filler))
  endif
endfunction

" Inspired by Ruby's with_index method.
function! s:with_index(list, ...) abort
  let base = a:0 > 0 ? a:1 : 0
  return map(copy(a:list), '[v:val, v:key + base]')
endfunction

" similar to Ruby's detect or Haskell's find.
function! s:find(list, default, f) abort
  let l:Call = type(a:f) is type(function('function'))
  \          ? function('call')
  \          : function('s:_call_string_expr')

  for x in a:list
    if l:Call(a:f, [x])
      return x
    endif
  endfor
  return a:default
endfunction

function! s:_call_string_expr(expr, args) abort
  return map([a:args[0]], a:expr)[0]
endfunction

" Returns the index of the first element which satisfies the given expr.
function! s:find_index(xs, f, ...) abort
  let len = len(a:xs)
  let start = a:0 > 0 ? (a:1 < 0 ? len + a:1 : a:1) : 0
  let default = a:0 > 1 ? a:2 : -1
  if start >=# len || start < 0
    return default
  endif
  for i in range(start, len - 1)
    if eval(substitute(a:f, 'v:val', string(a:xs[i]), 'g'))
      return i
    endif
  endfor
  return default
endfunction

" Returns the index of the last element which satisfies the given expr.
function! s:find_last_index(xs, f, ...) abort
  let len = len(a:xs)
  let start = a:0 > 0 ? (a:1 < 0 ? len + a:1 : a:1) : len - 1
  let default = a:0 > 1 ? a:2 : -1
  if start >=# len || start < 0
    return default
  endif
  for i in range(start, 0, -1)
    if eval(substitute(a:f, 'v:val', string(a:xs[i]), 'g'))
      return i
    endif
  endfor
  return default
endfunction

" Similar to find_index but returns the list of indices satisfying the given expr.
function! s:find_indices(xs, f, ...) abort
  let len = len(a:xs)
  let start = a:0 > 0 ? (a:1 < 0 ? len + a:1 : a:1) : 0
  let result = []
  if start >=# len || start < 0
    return result
  endif
  for i in range(start, len - 1)
    if eval(substitute(a:f, 'v:val', string(a:xs[i]), 'g'))
      call add(result, i)
    endif
  endfor
  return result
endfunction

" Return non-zero if a:list1 and a:list2 have any common item(s).
" Return zero otherwise.
function! s:has_common_items(list1, list2) abort
  return !empty(filter(copy(a:list1), 'index(a:list2, v:val) isnot -1'))
endfunction

function! s:intersect(list1, list2) abort
  let items = []
  " for funcref
  for X in a:list1
    if index(a:list2, X) != -1 && index(items, X) == -1
      let items += [X]
    endif
  endfor
  return items
endfunction

" similar to Ruby's group_by.
function! s:group_by(xs, f) abort
  let result = {}
  let list = map(copy(a:xs), printf('[v:val, %s]', a:f))
  for x in list
    let Val = x[0]
    let key = type(x[1]) !=# type('') ? string(x[1]) : x[1]
    if has_key(result, key)
      call add(result[key], Val)
    else
      let result[key] = [Val]
    endif
    unlet Val
  endfor
  return result
endfunction

function! s:_default_compare(a, b) abort
  return a:a <# a:b ? -1 : a:a ># a:b ? 1 : 0
endfunction

function! s:binary_search(list, value, ...) abort
  let Predicate = a:0 >= 1 ? a:1 : 's:_default_compare'
  let dic = a:0 >= 2 ? a:2 : {}
  let start = 0
  let end = len(a:list) - 1

  while 1
    if start > end
      return -1
    endif

    let middle = (start + end) / 2

    let compared = call(Predicate, [a:value, a:list[middle]], dic)

    if compared < 0
      let end = middle - 1
    elseif compared > 0
      let start = middle + 1
    else
      return middle
    endif
  endwhile
endfunction

function! s:product(lists) abort
  let result = [[]]
  for pool in a:lists
    let tmp = []
    for x in result
      let tmp += map(copy(pool), 'x + [v:val]')
    endfor
    let result = tmp
  endfor
  return result
endfunction

function! s:permutations(list, ...) abort
  if a:0 > 1
    throw 'vital: Data.List: too many arguments'
  endif
  let r = a:0 == 1 ? a:1 : len(a:list)
  if r > len(a:list)
    return []
  elseif r < 0
    throw 'vital: Data.List: {r} must be non-negative integer'
  endif
  let n = len(a:list)
  let result = []
  for indices in s:product(map(range(r), 'range(n)'))
    if len(s:uniq(indices)) == r
      call add(result, map(indices, 'a:list[v:val]'))
    endif
  endfor
  return result
endfunction

function! s:combinations(list, r) abort
  if a:r > len(a:list)
    return []
  elseif a:r < 0
    throw 'vital: Data.List: {r} must be non-negative integer'
  endif
  let n = len(a:list)
  let result = []
  for indices in s:permutations(range(n), a:r)
    if s:sort(copy(indices), 'a:a - a:b') == indices
      call add(result, map(indices, 'a:list[v:val]'))
    endif
  endfor
  return result
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
