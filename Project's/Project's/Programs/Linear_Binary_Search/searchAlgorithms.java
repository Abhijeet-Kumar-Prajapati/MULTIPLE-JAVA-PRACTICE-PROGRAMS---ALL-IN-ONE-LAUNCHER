import java.util.Arrays;

public class searchAlgorithms {
    public static int linearSearch(int[] arr, int target) {
        for (int i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                return i;
            }
        }
        return -1;
    }

    public static int binarySearch(int[] arr, int target) {
        int left = 0;
        int right = arr.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (arr[mid] == target) {
                return mid;
            }
            if (arr[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return -1;
    }

    public static void main(String[] args) {
        int array[] = { 34, 67, 23, 90, 12, 54 };
        int target = 90;
        int linearResult = linearSearch(array, target);
        if (linearResult == -1) {
            System.out.println("Element not found in linear search.");
        } else {
            System.out.println("Element found at index(linear search): " + linearResult);
        }
        Arrays.sort(array);
        int binaryResult = binarySearch(array, target);
        if (binaryResult == -1) {
            System.out.println("Element not found in the bimnary search.");
        } else {
            System.out.println("Element found at index(Binary Search): " + binaryResult);
        }
    }
}
