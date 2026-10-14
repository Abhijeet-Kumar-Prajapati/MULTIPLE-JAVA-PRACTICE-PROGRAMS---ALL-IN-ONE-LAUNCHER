class A {
    void display() {
        System.out.println("Display method of class A");
    }
}

class B extends A {
    void display() {
        System.out.println("Display method of class B");
    }
}

public class Main {

    public static void main(String[] args) {
        A obj = new B();
        obj.display();
    }
}