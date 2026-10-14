// Parent class
class Animal {
    // Method to be overridden in the child class
    void sound() {
        System.out.println("Animals make sounds");
    }
}

// Child class that overrides the sound method
class Dog extends Animal {
    // Overriding the sound method of Animal class
    @Override
    void sound() {
        System.out.println("The dog barks");
    }
}

// Another child class that overrides the sound method
class Cat extends Animal {
    // Overriding the sound method of Animal class
    @Override
    void sound() {
        System.out.println("The cat meows");
    }
}

public class Main {
    public static void main(String[] args) {
        // Creating objects of the child classes
        Animal myDog = new Dog();  // Polymorphism
        Animal myCat = new Cat();  // Polymorphism

        // Calling the overridden methods
        myDog.sound();  // Calls the sound method in Dog class
        myCat.sound();  // Calls the sound method in Cat class
    }
}
