module HistoryTree exposing ( HistoryTree, init, current, undo, redo, apply, push, goto )

{-| This library defines a tree structure that contains a complete history of
some parent and child states, with infinitely many different timelines.

You can undo/redo along this timeline, and continue to do new actions from any point in time, without losing the other timeline you had created earlier.

# Definition
@docs HistoryTree

# Creation and basic usage
@docs init, current, undo, redo

# Manipulation
@docs apply, push

# Changing focus
@docs goto
-}

import FocusTree exposing (FocusTree, Index)

{-| A tree that has a focus on a certain point in its history.
-}
type alias HistoryTree a = FocusTree a


{-| Make a new history tree with an initial (root) value.
-}
init : a -> HistoryTree a
init =
    FocusTree.init


{-| Try to undo one step on the current history tree.
Returns a `Just` value containing the new history tree if it's possible,
`Nothing` when already at the initial point of history.
-}
undo : HistoryTree a -> Maybe (HistoryTree a)
undo =
    FocusTree.goUp


{-| Try to redo a certain history child. These are numbered with Int indices.
Returns a `Just` value containing the history tree with the chosen child in focus,
`Nothing` when there is no child with the given index available.
-}
redo : Index -> HistoryTree a -> Maybe (HistoryTree a)
redo =
    FocusTree.goDown


{-| Push some new history entry onto the tree, and focus on it.
-}
push : a -> HistoryTree a -> HistoryTree a
push =
    FocusTree.insertAndFocus


{-| Push a new history entry calculated from the current value onto the tree, and focus on it.
Like `push`, but with the new value being a transformation of the current point in history.
-}
apply : (a -> a) -> HistoryTree a -> HistoryTree a
apply f tree =
    push (tree |> FocusTree.getCurrentValue |> f) tree


{-| Get the value at the current (focussed) point in history.
-}
current : HistoryTree a -> a
current =
    FocusTree.getCurrentValue


{-| Try to traverse the tree downwards to a certain point in history.
This is like repeated applications of `redo` - you can think of it as taking a described path to the point in history.
Returns a `Just` value containing the history tree with the chosen history point in focus,
`Nothing` when there is no history point at the given path to be found.
-}
goto : List Index -> HistoryTree a -> Maybe (HistoryTree a)
goto =
    FocusTree.traverseDownwards
