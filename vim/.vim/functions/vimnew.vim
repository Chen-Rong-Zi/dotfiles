vim9script
import "./higherorder.vim" as fp
import "./useful.vim"      as us

class Queue
    static var queue: list<number> = [0, &lines]
    public var upper: number
    public var lower: number

    def new(this.upper, this.lower)
    enddef

    def ReleasePlace(base: number, size: number)
        Queue.queue = fp.Filter(Queue.queue,
                                (_, pos: number) => pos < base || pos > base + size - 1)
        if base < this.upper
            this.upper = base - 1
        endif
    enddef

    def HoldPlace(base: number, size: number)
        Queue.queue = Queue.queue
                        ->extend(range(base, base + size - 1))
                        ->fp.Sorted((a: number, b: number): number => a - b)
        if base + size ># this.upper
            this.upper = base + size
        endif
    enddef

    def SearchSpace(size: number): number
        def LeastSpace(pre: number, curr: number): number
            echom string(pre) .. ' . ' .. string(curr)
            if Queue.queue->index(pre) ==# -1
                return pre
            elseif curr - pre - 1 >=# size
                return pre + 1
            endif
            return curr
        enddef
        return fp.Reduce(Queue.queue, LeastSpace, this.upper)
    enddef

    def Allocate(size: number): number
        # find the postion
        const base: number = this.SearchSpace(size)
        this.HoldPlace(base, size)
        return base
    enddef
endclass

var c = Queue.new(0, &lines)
def Test()
    echo c.Allocate(10)
enddef

def Out(abc: number): func
    def Iner(): number
        return abc
    enddef
    return Iner
enddef
var S = Out(10)
# echo S()
var [_, row, col, _] = getpos('.')
var a = us.Pair.new('[', ']', row, col, us.SearchStrategy.InnerStrategy)


# cursor(a.l_row, a.l_col)
# a.Show()
#echo Queue.GetQueue()
# us.ReplacePairs()
# us.Match()

# var a = Queue.new([0, &lines], 1, &lines - 1)
#echo a.queue
# echo fp.Mapped((_, v) => v * 20)([1, 2, 3, 4, 5])
# echo us.Cword()

# echo us.FileType('/home/rongzi/.vimrc.cpp')
# us.Complete()
# us.CR()

var pos = us.Position.new(1, 1)
var pos1 = us.Position.new(0, 2)
var pos2 = us.Position.new(1, 0)
echom pos.row .. " "  .. pos.col
echom us.Position.Compare(pos, pos1, pos2)

class B
    var member: number

    def new(member: number)
        this.member = member
    enddef

    def Get()
        GetMember(this)
    enddef
endclass

def GetMember(bobject: B)
    echom bobject.member
enddef


var asfd = B.new(123)
asfd.Get()

