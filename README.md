# cobalamin/history-tree

This is an Elm library implementing a data structure to represent a multi-timeline history in the form of a tree.

It's meant for implementing an undo/redo functionality where, when you undo to some point and then do something else from there, you don't lose that entire timeline of things you had done previously.

*This library does not implement the undo/redo functionality with a usable frontend, but only a data structure that can be used for it. I will implement this in a different library.*

--

A simple example in ASCII art. `(x)` represents a node with the value x, `<x>` represents the currently active state.

```
       (1)              (1)               (1)
        |                |                 |
       (2)     ->       <2>       ->      (2)
        |                |               /   \ 
       <3>              (3)            (3)   <1>

 You increment a    You undo your     You choose to
 counter three      last action,      decrement the
 times.             making 2 the      counter instead.
                    current state.   
```

As you can see, the previous timeline (1 -> 2 -> 3) is kept in a separate branch of the tree, and you can switch to it again at any time.
