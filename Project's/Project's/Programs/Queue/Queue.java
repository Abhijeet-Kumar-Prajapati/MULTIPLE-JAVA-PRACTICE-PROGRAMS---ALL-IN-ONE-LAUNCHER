class Queue {
    private int[] queue;
    private int front;
    private int rare;
    private int capacity;
    private int size;

    public Queue(int capacity) {
        this.capacity = capacity;
        queue = new int[capacity];
        front = 0;
        rare = -1;
        size = 0;
    }

    public void enqueue(int element) {
        if (isFull()) {
            System.out.println("Queue Overflow");
            return;
        }
        rare = (rare + 1) % capacity;
        queue[rare] = element;
        size++;
        System.out.println("Enqueued" + element);
    }

    public int dequeue() {
        if (isEmpty()) {
            System.out.println("Queue Underflow");
            return -1;
        }
        int element = queue[front];
        front = (front + 1) % capacity;
        size--;
        return element;
    }

    public int peek() {
        if (!isEmpty()) {
            return queue[front];
        } else {
            System.out.println("Queue is Empty");
            return -1;
        }
    }

    public boolean isEmpty() {
        return size == 0;
    }

    public boolean isFull() {
        return size == capacity;
    }

    public void display() {
        if (isEmpty()) {
            System.out.println("Queue is empty");
        } else {
            System.out.println("Queue elements:");
            for (int i = 0; i < size; i++) {
                System.out.println(queue[(front + i) % capacity] + " ");
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {
        Queue queue = new Queue(5);
        queue.enqueue(10);
        queue.enqueue(20);
        queue.enqueue(30);
        queue.enqueue(40);
        queue.enqueue(50);
        queue.display();
        System.out.println("peek:" + queue.peek());
        System.out.println("Dequeued:" + queue.dequeue());
        System.out.println("Dequeued:" + queue.dequeue());
        queue.display();
    }
}