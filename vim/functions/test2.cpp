# include <cstring>

class A {
    int x, y;
public:
    A(int i, int j) {x = i; y = j;};
    void *operator new (size_t size, void *p) {
        return p;
    }
};

int main(int arg_number, char **arg_value) {
    char buf[sizeof(A)];
    A *p = new(buf) A(1, 2);
    p->~A();
    return 0;
}
