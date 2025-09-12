# Stacks and Queue
# A stack is a Last In, First Out (LIFO) data structure where the last element added is the first to be removed.
# This implementation provides methods to push, pop, peek, and check if the stack is empty.


class Stack:
    """
    A class to represent a stack data structure.

    Attributes
    ----------
    stack : list
        A list to store the elements of the stack.

    Methods
    -------
    push(item):
        Adds an item to the top of the stack.
    
    is_empty():
        Checks if the stack is empty.
    
    pop():
        Removes and returns the item at the top of the stack.
        Returns "Stack is Empty" if the stack is empty.
    
    peek():
        Returns the item at the top of the stack without removing it.
        Returns None if the stack is empty.
    """

    def __init__(self) -> None:
        """Initializes an empty stack."""
        self.stack = []

    def push(self, item):
        """Adds an item to the top of the stack.

        Parameters
        ----------
        item : any
            The item to be added to the stack.
        """
        self.stack.append(item)

    def is_empty(self):
        """Checks if the stack is empty.

        Returns
        -------
        bool
            True if the stack is empty, False otherwise.
        """
        return len(self.stack) == 0
    
    def pop(self):
        """Removes and returns the item at the top of the stack.

        Returns
        -------
        any
            The item at the top of the stack, or "Stack is Empty" if the stack is empty.
        """
        if not self.is_empty():
            return self.stack.pop()
        return "Stack is Empty"
    
    def peek(self):
        """Returns the item at the top of the stack without removing it.

        Returns
        -------
        any
            The item at the top of the stack, or None if the stack is empty.
        """
        if not self.is_empty():
            return self.stack[-1]
        return None
        
    

    