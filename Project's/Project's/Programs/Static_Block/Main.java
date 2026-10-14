class Demo {
    static {
        System.out.println("Static block is executed before the main method:");
    }

    Demo() {
        System.out.println("Constructor is called.");
    }

    static void displayMessage() {
        System.out.println("Static method is called.");
    }
}

public class Main {
    public static void main(String[] args) {
        Demo.displayMessage();
        Demo obj = new Demo();
    }
}
