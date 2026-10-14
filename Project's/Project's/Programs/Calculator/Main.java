package Calculator;

class Calculator {
    int a, b;

    Calculator() {
        this.a = 0;
        this.b = 0;
    }

    Calculator(int a, int b) {
        this.a = a;
        this.b = b;
    }

    int add(int x, int y) {
        return x + y;
    }

    int add(int x, int y, int z) {
        return x + y + z;
    }

    double add(double x, double y) {
        return x + y;
    }
}

public class Main {

    public static void main(String[] args) {
        Calculator calc1 = new Calculator();
        Calculator calc2 = new Calculator(10, 20);
        System.out.println("calc1 (default) values:a=" + calc1.a + ",b=" + calc1.b);
        System.out.println("calc2 (parameterized) values:a=" + calc2.a + ",b=" + calc2.b);
        System.out.println("Addition of two integers:" + calc2.add(5, 10));
        System.out.println("Addition of three integers:" + calc2.add(1, 2, 3));
        System.out.println("Addition of two double integers:" + calc2.add(2.5, 3.5));
    }
}