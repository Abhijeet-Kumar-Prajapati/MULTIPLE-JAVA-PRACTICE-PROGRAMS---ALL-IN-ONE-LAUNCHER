public class QuickSort {
    public static void quickSort(int[] arr, int low, int high) {
        if (low < high) {
            int pi = partition(arr, low, high);
            quickSort(arr, low, pi - 1);
            quickSort(arr, pi + 1, high);
        }
    }

    public static int partition(int[] arr, int low, int high) {
        int pivot = arr[high];
        int i = (low - 1);
        for (int j = low; j < high; j++) {
            if (arr[j] <= pivot) {
                i++;
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
        int temp = arr[i + 1];
        arr[i + 1] = arr[high];
        arr[high] = temp;
        return i + 1;
    }

    public static void printArray(int[] arr) {
        for (int i : arr) {
            System.out.println(i + " ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        int[] array = { 10, 7, 8, 9, 1, 5 };
        System.out.println("Orginal Array: ");
        printArray(array);
        quickSort(array, 0, array.length - 1);
        System.out.println("Sorted Array: ");
        printArray(array);
    }
}
