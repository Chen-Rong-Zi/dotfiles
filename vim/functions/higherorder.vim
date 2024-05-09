vim9script

export def Identity(x: any): any
    return x
enddef

export def Compare(a: number, b: number): bool
    return a > b
enddef

export def Sort(data: list<any>, How: func = Compare): list<any>
    return data->deepcopy()->sort(How)
enddef

export def Reversed(data: list<any>): list<any>
    return data->deepcopy()->reverse()
enddef

export def Curry1(Expr: func): func
    return (x: any) => Expr(x)
enddef

export def Curry2(Expr: func): func
    return (x: any) => (y) => Expr(x, y)
enddef

export def Curry3(Expr: func): func
    return (x: any) => (y: any) => (z: any) => Expr(x, y, z)
enddef

export def Curry4(Expr: func): func
    return (w: any) => (x: any) => (y: any) => (z: any) => Expr(w, x, y, z)
enddef

export def Map(data: list<any>, Expr: func): list<any>
    return data->deepcopy()->map(Expr)
enddef

export def Appended(data: list<any>, ele: any): list<any>
    return data->deepcopy()->add(ele)
enddef

export def Poped(data: list<any>, index: number): list<any>
    return data->deepcopy()->remove(index)
enddef

export def Filter(data: list<any>, Expr: func(number, any): bool): list<any>
    return data->deepcopy()->filter(Expr)
enddef

export def Reduce(data: list<any>, Expr: func, initial: any): any
    return data->deepcopy()->reduce(Expr, initial)
enddef


export def Prop(key: string): any
    return (data: dict<any>) => data[key]
enddef

export def Sorted(How: func = Compare): func
    return (data: list<any>): list<any> => Sort(data, How)
enddef

export def Mapped(Expr: func: any): func(list<any>): list<any>
    return (data: list<any>): list<any> => Map(data, Expr)
enddef

export def Filtered(Expr: func): func(list<any>): list<any>
    return (data: list<any>): list<any> => Filter(data, Expr)
enddef

export def Reduced(Expr: func, initial: any): any
    return (data: list<any>) => Reduce(data, Expr, initial)
enddef

export def Compose(...func_list: list<func>): any
    return Reduce(func_list,
             (Pre: func, Curr: func ) =>
                (arg: any) => Curr(Pre(arg)),
             Identity)
enddef

export def Trace(x: any): any
    echom "trace: " .. string(x)
    return x
enddef

export def Sum(x: list<number>): number
    const Add = (pre: number, curr: number): number => pre + curr
    return Reduce(x, Add, 0)
enddef

export def IndexAll(lst: list<any>, x: any): list<number>
    return lst->Map((i, v) => [i, v])->Filter((_, v) => v[1] ==# x)->Map((_, v) => v[0])
enddef
defcompile
