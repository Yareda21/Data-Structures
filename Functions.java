import java.util.Random;
import java.util.Scanner;

public class Functions {
    public static void main(String[] arg) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Enter a calculation: ");
        String input = scanner.nextLine();

        String[] numbers = input.split("\\+");
        int num1 = Integer.parseInt(numbers[0]);
        int num2 = Integer.parseInt(numbers[1]);

        int result = num1 + num2;
        System.out.println("Result: " + result);
        

        DiceRoll();;
    }


    public static void Chatbot (String args) {
        String[] response = {"Hello!", "Hi!", "Hey!"};
        Random random = new Random();
        Scanner scanner = new Scanner(System.in);


        while (true) {
            System.out.print("You: ");
            String input = scanner.nextLine();

            if (input.equalsIgnoreCase("quit")){
                break;
            } else if (input.contains("hello") || input.contains("hi")) {
                System.out.println("Chatty:" + response[random.nextInt(response.length)]);
            } else {
                System.out.println("I dont understand!!");
            }
        }
    }


    public static void DiceRoll() {
        Random random = new Random();
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.print("Enter number of dice: ");
            int numDice = scanner.nextInt();
            System.out.print("Enter Number of sides, default 6: ");
            int numSides = scanner.nextInt();
            
            int total = 0;
            for (int i=0; i < numDice; i++) {
                int roll = random.nextInt(numSides);
                total += roll;
                System.out.println("Dice " + (i+1) + ": " + roll);
            }

            System.out.println("Total: "+total);
            System.out.println("Would you like to roll again? (yes/no)");
            String input = scanner.next();
            if (input.equalsIgnoreCase("no")){
                break;
            }
        }
    }

    
}