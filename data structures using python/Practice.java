

class StackI {
    // new list used as a stack
    private int[] stack;

    // use as index to track the elem
    private int top;

    // the max number of ele, since java requires it
    private int size;


    public StackI(int capacity) {
        stack = new int[capacity];
        top = -1;
        size = 0;
    }

    public void push(int item) {
        if (size == stack.length) {
            throw new StackOverflowError("Stack is full!!");
        }

        this.stack[++top] = item;
        size++;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    public int pop(){
        if (isEmpty()){
            throw new IllegalStateException("Stack is Empty!!");
        }
        size--;
        return this.stack[top--];
    }
}


public class Practice {

    
    
    public static void main(String[] args) {
        StackI myStackI = new StackI(10);

        myStackI.isEmpty();
        
    }
}
