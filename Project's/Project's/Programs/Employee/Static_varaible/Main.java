class Counter {
    static int objectCount = 0;

    Counter() {
        objectCount++;
    }

    static void displayCount() {
        System.out.println("Total number of objects created:" + objectCount);
    }
}

public class Main {
    public static void main(String[] args) {
        Counter obj1 = new Counter();
        Counter obj2 = new Counter();
        Counter obj3 = new Counter();
        Counter.displayCount();
    }
}