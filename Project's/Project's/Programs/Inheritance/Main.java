class Animal {
    void sound() {
        System.out.println("Animal Makes Sounds");
    }
}

class Dog extends Animal {
    void bark() {
        System.out.println("The Dog Bark");
    }
}

class Cat extends Animal {
    void meow() {
        System.out.println("The Cat Meow");
    }
}

public class Main {
    public static void main(String[] args) {
        Dog dog = new Dog();
        dog.sound();
        dog.bark();

        Cat cat = new Cat();
        cat.sound();
        cat.meow();
    }
}
