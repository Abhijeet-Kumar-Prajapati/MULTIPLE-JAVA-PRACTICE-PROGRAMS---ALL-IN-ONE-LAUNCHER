class Circle {
    double radius;

    Circle(double r) {
        radius = r;
    }

    double area() {
        return Math.PI * radius * radius;
    }

}

public class Main {
    public static void main(String[] args) {
        Circle c = new Circle(5.0);
        System.out.println("Area of the Circle:" + c.area());
    }
}