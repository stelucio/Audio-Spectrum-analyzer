// RISC-V BOSS FIGHT STRESS TEST

// Funzione ricorsiva: calcola il n-esimo numero di Fibonacci
// Stressa: Stack Pointer, JAL, JALR, salvataggio registri (ra, s0)
int fib(int n) {
    if (n <= 1) return n;
    return fib(n-1) + fib(n-2);
}

// Funzione iterativa: somma dei quadrati
// Stressa: Loop, ALU, moltiplicazione software (se il compilatore la emette)
int sum_squares(int n) {
    int sum = 0;
    for (int i = 1; i <= n; i++) {
        sum += (i * i);
    }
    return sum;
}

int main() {
    volatile int *mem = (volatile int *)0x800;
    
    // Test 1: Fibonacci(7)
    // Sequenza: 0, 1, 1, 2, 3, 5, 8, 13
    // Risultato atteso: 13 (0xD)
    int f7 = fib(7);
    mem[0] = f7; // Scrive a 0x800

    // Test 2: Somma quadrati 1..5
    // 1^2 + 2^2 + 3^2 + 4^2 + 5^2 = 1 + 4 + 9 + 16 + 25 = 55
    // Risultato atteso: 55 (0x37)
    int s5 = sum_squares(5);
    mem[1] = s5; // Scrive a 0x804

    // Test 3: Logica booleana complessa
    // Risultato atteso: 0xCAFEBABE se vero, 0xDEADBEEF se falso
    int check = ((f7 == 13) && (s5 == 55)) ? 0xCAFEBABE : 0xDEADBEEF;
    mem[2] = check; // Scrive a 0x808

    return 0;
}
