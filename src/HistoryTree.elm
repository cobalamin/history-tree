module HistoryTree exposing
    ( HistoryTree
    , Index
    , init
    , current
    , undo
    , redo
    , canUndo
    , canRedo
    , branchCount
    , apply
    , push
    , goto
    , rewind
    )

{-| This library defines a tree structure that contains a complete history of
some parent and child states, with infinitely many different timelines.

You can undo/redo along this timeline, and continue to do new actions from any point in time, without losing the other timeline you had created earlier.

# Definition
@docs HistoryTree, Index

# Creation and basic usage
@docs init, current, undo, redo, branchCount

# Manipulation
@docs apply, push

# Checks
@docs canUndo, canRedo

# Changing focus
@docs goto, rewind
-}

import FocusTree exposing (FocusTree, Tree)

{-| The index pointing at a certain subtree. An alias for Int.
-}
type alias Index = FocusTree.Index

{-| A tree that has a focus on a certain point in its history.
-}
type alias HistoryTree a = FocusTree a


{-| Make a new history tree with an initial (root) value.
-}
init : a -> HistoryTree a
init =
    FocusTree.init


{-| Get the value at the current (focussed) point in history.
-}
current : HistoryTree a -> a
current =
    FocusTree.getCurrentValue


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


{-| Returns the count of child timeline branches from the currently focussed point.
Can be used to e.g. show several different Redo buttons for each child branch.
-}
branchCount : HistoryTree a -> Int
branchCount =
    FocusTree.branchCount


{-| Push a new history entry calculated from the current value onto the tree, and focus on it.
Like `push`, but with the new value being a transformation of the current point in history.
-}
apply : (a -> a) -> HistoryTree a -> HistoryTree a
apply f tree =
    push (tree |> current |> f) tree


{-| Push some new history entry onto the tree, and focus on it.
-}
push : a -> HistoryTree a -> HistoryTree a
push =
    FocusTree.insertAndFocus


{-| Returns True if there is a previous (parent) point in history to switch to,
False if we're already at the earliest point in time.

This is useful for UIs based on using these trees: You can, for example, disable an "Undo" button if this returns False.
-}
canUndo : HistoryTree a -> Bool
canUndo =
    FocusTree.canGoUp

{-| Returns True if there is any later (child) points in history to switch to,
False if we're at a point in time that has no child points in time.

This can be useful for the same reasons as `canUndo`. It might be a bit too generic for most use cases, since there's possibly multiple redo paths to take.
-}
canRedo : HistoryTree a -> Bool
canRedo =
    FocusTree.canGoDown


{-| Try to traverse the tree downwards to a certain point in history.
This is like repeated applications of `redo` - you can think of it as taking a described path to the point in history.
Returns a `Just` value containing the history tree with the chosen history point in focus,
`Nothing` when there is no history point at the given path to be found.
-}
goto : List Index -> HistoryTree a -> Maybe (HistoryTree a)
goto =
    FocusTree.traverseDownwards


{-| Rewind history, focussing on the first point in time.
Useful for drawing a tree, since for that, you need to traverse it downwards from the top.
-}
rewind : HistoryTree a -> HistoryTree a
rewind =
    FocusTree.goToTop
