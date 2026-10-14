class Animal {
    String color = "White";

    void eat() {
        System.out.println("Animal is eating");
    }
}

class Dog extends Animal {
    String color = "Black";

    void displayColor() {
        System.out.println("Dog Color: " + color);
        System.out.println("Animal Color: " + super.color);
    }

    void eat() {
        super.eat();
        System.out.println("Dog is eating");
    }
}

public class Main {
    public static void main(String[] args) {
        Dog d = new Dog();
        d.displayColor();
        d.eat();
    }
}