function! Sorted(data)
    " a:data is either list or dict
    return a:data->deepcopy()->sort()
endfunction

function! Reversed(data)
    " a:data is either list or dict
    return a:data->deepcopy()->reverse()
endfunction

function! Map(data, expr)
    " a:data is either list or dict
    return a:data->deepcopy()->map(a:expr)
endfunction

function! Appended(list, expr)
    return a:list->deepcopy()->add(a:expr)
endfunction

function! Poped(data, index)
    let new_data = a:data->deepcopy()
    call remove(new_data, a:index)
    return new_data
endfunction

function! Filter(data, expr)
    return a:data->deepcopy()->filter(a:expr)
endfunction

function! Assoc(data, value, index)
    return a:data->deepcopy()->insert(a:value, a:index)
endfunction

function! Reduce(data, func, ...)
    if a:0 ==# 1
        return a:data->deepcopy()->reduce(a:func, a:000[0])
    elseif a:0 ==# 0
        return a:data->deepcopy()->reduce(a:func)
    else
        echoerr "Reduced只能接受两个或三个参数！"
    endif
endfunction
