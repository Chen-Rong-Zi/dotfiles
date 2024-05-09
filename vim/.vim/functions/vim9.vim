vim9script

export def Outter9(): func
    var a: number = 0
    def Inner9(): number
        a += 1
        return a
    enddef
    return Inner9
enddef

export def Fib2(n: number): number
    if n <=# 0
        return 1
    endif
    return Fib2(n - 1) + Fib2(n - 2)
enddef

export def A(n: number): number
    var b: number = 3
    echom b
    return 0
enddef

var closures: list<func>
for i in range(10)
    var inloop = i
    closures[i] = () => inloop
endfor
echo closures
    ->len()
    ->range()
    ->map((i, _) => closures[i]())

defcompile

