public class Main {
    public static void main(String[] args) {
        int[] numbers = { 1, 2, 3 };
        int result = 0;

        try {
            // Trying to divide by zero, which will cause an ArithmeticException
            result = 10 / 0;
            System.out.println("This line will not be executed.");
        } catch (ArithmeticException e) {
            // Catching the ArithmeticException and handling it
            System.out.println("Error: Cannot divide by zero.");
        }

        try {
            // Trying to access an array element that doesn't exist
            System.out.println("Accessing element at index 5: " + numbers[5]);
        } catch (ArrayIndexOutOfBoundsException e) {
            // Catching the ArrayIndexOutOfBoundsException and handling it
            System.out.println("Error: Array index out of bounds.");
        }

        finally {
            // This block always executes
            System.out.println("The 'finally' block is always executed.");
        }

        System.out.println("Program continues after exception handling.");
    }
}
