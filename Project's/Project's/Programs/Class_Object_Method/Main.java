class Car {
    String brand;
    String model;
    int year;

    Car(String brand, String model, int year) {
        this.brand = brand;
        this.model = model;
        this.year = year;
    }

    void displayInfo() {
        System.out.println("Brand:" + brand);
        System.out.println("Model:" + model);
        System.out.println("Year:" + year);
    }
}

public class Main {
    public static void main(String[] args) {
        Car car1 = new Car("Toyota", "Camry", 2020);
        Car car2 = new Car("Honda", "Civic", 2022);
        System.out.println("Car1 Info");
        car1.displayInfo();
        System.out.println("Car2 Info");
        car2.displayInfo();
    }
}
