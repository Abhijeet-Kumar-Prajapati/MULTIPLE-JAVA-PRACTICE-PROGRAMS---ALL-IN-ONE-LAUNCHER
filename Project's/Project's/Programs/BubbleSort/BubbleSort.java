public class BubbleSort {
    public static void bubbleSort(int[] arr) {
        int n = arr.length;
        for (int i = 0; i < n - 1; i++) {
            boolean swapped = false;
            for (int j = 0; j < n - 1 - i; j++) {
                if (arr[j] > arr[j + 1]) {
                    int temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                    swapped = true;
                }
            }
            if (!swapped) {
                break;
            }
        }
    }

    public static void printArray(int[] arr) {
        for (int i : arr) {
            System.out.println(i + " ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        int[] array = { 64, 34, 25, 12, 22, 11, 90 };
        System.out.println("Orginal Array: ");
        printArray(array);
        bubbleSort(array);
        System.out.println("Sorted Array:");
        printArray(array);
    }
}
