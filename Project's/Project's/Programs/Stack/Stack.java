class Stack {
    private int[] stack;
    private int top;
    private int capacity;

    public Stack(int size) {
        stack = new int[size];
        capacity = size;
        top = -1;
    }

    public void push(int element) {
        if (isFull()) {
            System.out.println("Stack Overflow");
            return;
        }
        stack[++top] = element;
        System.out.println("Pushed " + element);
    }

    public int pop() {
        if (isEmpty()) {
            System.out.println("Stack Underflow");
            return -1;
        }
        return stack[top--];
    }

    public int peek() {
        if (!isEmpty()) {
            return stack[top];
        } else {
            System.out.println("Stack is empty");
            return -1;
        }
    }

    public boolean isEmpty() {
        return top == -1;
    }

    public boolean isFull() {
        return top == capacity - 1;
    }

    public void display() {
        if (isEmpty()) {
            System.out.println("Stack is empty");
        } else {
            System.out.println("Stack elements: ");
            for (int i = 0; i <= top; i++) {
                System.out.println(stack[i] + " ");
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {
        Stack stack = new Stack(5);
        stack.push(10);
        stack.push(20);
        stack.push(30);
        stack.push(40);
        stack.push(50);
        stack.display();
        System.out.println("Peek: " + stack.peek());
        System.out.println("Popped: " + stack.pop());
        System.out.println("Popped: " + stack.pop());
        stack.display();
    }
}