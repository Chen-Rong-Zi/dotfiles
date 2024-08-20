vim9script
class Obj
    public var value: number
    def new()
        this.value = 1
    enddef
    def Func(type: string)
        echom '1 + 0 = ' .. this.value
    enddef
endclass

def Func()
    legacy let a = Obj.new()
    set operatorfunc=function(g:a.Func)
enddef

Func()
