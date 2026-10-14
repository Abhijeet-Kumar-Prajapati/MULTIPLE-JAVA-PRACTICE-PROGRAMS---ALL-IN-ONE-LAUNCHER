import java.util.Scanner;

class Employee {
    String name;
    int id;
    String department;
    double salary;

    void getDetails() {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter Employee ID:");
        id = scanner.nextInt();
        scanner.nextLine();
        System.out.print("Enter Employee Name:");
        name = scanner.nextLine();
        System.out.print("Enter Employee Department:");
        department = scanner.nextLine();
        System.out.print("Enter Employee Salary:");
        salary = scanner.nextDouble();
    }

    void displayDetails() {
        System.out.println("\nEmployee Details:");
        System.out.println("ID:" + id);
        System.out.println("Name:" + name);
        System.out.println("Department:" + department);
        System.out.println("Salary:" + salary);
    }
}

public class Main {
    public static void main(String[] args) {
        Employee emp = new Employee();
        emp.getDetails();
        emp.displayDetails();
    }
}
