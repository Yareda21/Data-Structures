/**
 * A custom stack implementation using an array.
 */
class CustomeStack {
    private int[] stack;
    private int top;
    private int size;


    /**
     * Constructs a CustomeStack with a specified capacity.
     * 
     * @param capacity the maximum number of elements the stack can hold
     */
    public CustomeStack(int capacity) {
        stack = new int[capacity];
        top = -1;
        size = 0;
    }

    /**
     * Pushes an item onto the top of the stack.
     * 
     * @param item the item to be pushed onto the stack
     * @throws StackOverflowError if the stack is full
     */
    public void push(int item) {
        if (size == stack.length) {
            throw new StackOverflowError("Stack is Full");
        }

        stack[++top] = item;
        size++;
    }

    /**
     * Checks if the stack is empty.
     * 
     * @return true if the stack is empty, false otherwise
     */
    public boolean isEmpty() {
        return size == 0;
    }
    
    /**
     * Pops the top item off the stack.
     * 
     * @return the item that was removed from the top of the stack
     * @throws IllegalStateException if the stack is empty
     */
    public int pop() {
        if (isEmpty()){
            throw new IllegalStateException("Stack is Empty");
        }
        size--;
        return stack[top--];
    }

    /**
     * Peeks at the top item of the stack without removing it.
     * 
     * @return the item at the top of the stack
     * @throws IllegalStateException if the stack is empty
     */
    public int peek(){
        if (isEmpty()){
            throw new IllegalStateException("Stack is empty");
        }
        return stack[top];
    }

    /**
     * Returns the current size of the stack.
     * 
     * @return the number of elements in the stack
     */
    public int getsize() {
        return size;
    }
}

/**
 * Main class to demonstrate the functionality of the CustomeStack.
 */
public class Module2 {

    public static void main(String[] arg) {
        CustomeStack stack = new CustomeStack(5);

        stack.push(10);
        stack.push(20);

        System.out.println("Front: " + stack.peek());
        System.out.println("Popped: " + stack.pop());
        System.out.println("Is Empty: " + stack.isEmpty());


    }
}