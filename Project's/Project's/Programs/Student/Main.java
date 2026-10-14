package Student;

class Student {
    String name;
    int rollNo;
    int age;
    String college;

    void displayDetails() {
        System.out.println("Student Name:" + name);
        System.out.println("Roll No:" + rollNo);
        System.out.println("Age:" + age);
        System.out.println("College:" + college);
    }
}

public class Main {
    public static void main(String[] args) {
        Student student1 = new Student();
        student1.name = "Sukumar Gope";
        student1.rollNo = 101;
        student1.age = 20;
        student1.college = "UCET Hazaribag";
        student1.displayDetails();
    }
}
