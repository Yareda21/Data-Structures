import java.util.Scanner;

public class Search {
    public static void main(String[] args){
        Scanner scanner = new Scanner(System.in);
        
        int nums[] = {2, 3, 5, 6, 8, 9};

        System.out.println("Enter Search Type: ");
        System.out.println("1. Linear Search");
        System.out.println("2. Binary Search with while loop");
        System.out.println("3. Recursive Binary Search");
        int choice = scanner.nextInt();
        
        System.out.println("Enter Target: ");
        int target = scanner.nextInt();
        int answer;

        if (choice == 1) {

            answer = linearSearch(nums, target);

        } else if (choice == 2) {

            answer = binarySearch(nums, target);
        } else if (choice == 3) {
            
            int left = 0;
            int steps = 0;
            int right = nums.length-1;

    
            answer = recursiveBinary(nums, target, left, right, steps);
        } else {
            System.out.println("Out of reach");
            scanner.close();
            return;
        }
   
        if (answer != -1) {
            System.out.println("The location of target: " + answer);
        } else {
            System.out.println("Target not found!!");
        }

        scanner.close();
    }
    

    public static int linearSearch(int nums[], int target) {
        int steps = 0;
        for (int i=0; i<nums.length; i++) {
            steps++;
            if (target == nums[i]){
                System.out.println("Number of steps taken by linear: " + steps);
                return i;
            }
        }
        
        System.out.println("Number of steps taken by linear: " + steps);
        return -1;
    }


    public static int binarySearch(int[] nums, int target) {
        int left = 0;
        int right = nums.length - 1;
        int steps = 0;
        while (left <= right) {
            int mid = (left + right) / 2 ;
            steps++;
            if (nums[mid] == target) {
                System.out.println("Number of steps taken by Binary: " + steps);
                return mid;
                
            }
            else if (nums[mid] < target) left = mid+ 1;
            else if (nums[mid] > target) right = mid - 1;
        }
        
        System.out.println("Number of steps taken by Binary: " + steps);
        return -1;
    }


    public static int recursiveBinary(int[] nums, int target, int left, int right, int steps) {
        int mid = (left + right) / 2;
        steps++;
        if (target == nums[mid]){
            System.out.println("Number of steps taken by Recursive Binary: " + steps);
            return mid;
        } else if (nums[mid] > target) {
            right = mid - 1;
            return recursiveBinary(nums, target, left, right, steps);
            
        } else if (nums[mid] < target ) {
            left = mid + 1;
            return recursiveBinary(nums, target, left, right, steps);
        }
        return -1;

    }
}