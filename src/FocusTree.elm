module FocusTree exposing
    ( FocusTree
    , Tree
    , Index

    , init
    , getCurrentValue
    , branchCount
    , goUp
    , goDown
    , canGoUp
    , canGoDown

    , insertAndFocus
    , traverseDownwards
    , goToTop
    )

import Array exposing (Array)
import Maybe exposing (andThen)
import Tree exposing (Tree(..))

type alias Index = Tree.Index
type alias Tree a = Tree.Tree a

type Crumb a =
    Crumb Index a (Array (Tree a))

type alias Crumbs a = List (Crumb a)

type FocusTree a = FocusTree (Tree a) (Crumbs a)


getCurrentValue : FocusTree a -> a
getCurrentValue (FocusTree tree _) =
    Tree.getValue tree


branchCount : FocusTree a -> Int
branchCount (FocusTree (Node _ children) _) =
    Array.length children


init : a -> FocusTree a
init value =
    FocusTree (Tree.leaf value) []


insertChild : a -> FocusTree a -> (Index, FocusTree a)
insertChild childValue (FocusTree tree crumbs) =
    let
        childTree =
            Tree.leaf childValue
    in
        case tree of
            Node value children ->
                ( Array.length children
                , FocusTree (Node value (Array.push childTree children)) crumbs
                )


insertAndFocus : a -> FocusTree a -> FocusTree a
insertAndFocus value tree =
    let
        (index, newFocusTree) =
            insertChild value tree

        forceGoDown index tree =
            case goDown index tree of
                Nothing ->
                    Debug.crash """
                                Huh. We tried to insert and refocus on a new child but couldn't step downwards.
                                This shouldn't occur. Please report a bug.
                                """
                Just newFocusTree ->
                    newFocusTree
    in
        forceGoDown index newFocusTree


goDown : Index -> FocusTree a -> Maybe (FocusTree a)
goDown index (FocusTree (Node value subtrees) crumbs) =
    Tree.getSubtreeAt subtrees index `andThen` \ (subtree, otherSubtrees) ->
        Just <| FocusTree subtree (Crumb index value otherSubtrees :: crumbs)


canGoDown : FocusTree a -> Bool
canGoDown (FocusTree (Node _ subtrees) _) =
    not (Array.isEmpty subtrees)


traverseDownwards : List Index -> FocusTree a -> Maybe (FocusTree a)
traverseDownwards indices focusTree =
    let
        go index maybeTree =
            maybeTree `andThen` \tree ->
                goDown index tree
    in
        List.foldl go (Just focusTree) indices


goUp : FocusTree a -> Maybe (FocusTree a)
goUp (FocusTree tree crumbs) =
    case crumbs of
        [] ->
            Nothing

        (Crumb index value siblingTrees) :: parentCrumbs ->
            let
                familyReunion =
                    insertIntoArray index tree siblingTrees
            in
                Just <| FocusTree (Node value familyReunion) parentCrumbs


canGoUp : FocusTree a -> Bool
canGoUp (FocusTree _ crumbs) =
    not (List.isEmpty crumbs)


insertIntoArray : Index -> a -> Array a -> Array a
insertIntoArray index value array =
    joinArraysWith
        (Array.slice 0 index array)
        (Array.slice index (Array.length array) array)
        value


joinArraysWith : Array a -> Array a -> a -> Array a
joinArraysWith l r value =
    Array.append l (Array.fromList [value])
        |> flip Array.append r


goToTop : FocusTree a -> FocusTree a
goToTop ((FocusTree tree crumbs) as focus) =
    case goUp focus of
        Nothing ->
            FocusTree tree []

        Just parentFocus ->
            goToTop parentFocus

