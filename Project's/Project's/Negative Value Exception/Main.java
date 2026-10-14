class NegativeValueException extends Exception {
    public NegativeValueException(String message) {
        super(message);
    }
}

public class Main {
    public static void checkValue(int value) throws NegativeValueException {
        if (value < 0) {
            throw new NegativeValueException("Negative Values are not allowed:" + value);
        } else {
            System.out.println("Value entered is:" + value);
        }
    }

    public static void main(String[] args) {
        try {
            checkValue(-10);
        } catch (NegativeValueException e) {
            System.out.println(e.getMessage());
        }
    }
}