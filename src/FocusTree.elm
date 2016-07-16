module FocusTree exposing (FocusTree, Tree, Index, init, goUp, goDown, traverseDownwards, insertAndFocus, unfocus, getCurrentValue)

import Array exposing (Array)
import Maybe exposing (andThen)
import Tree exposing (Tree(..))

type alias Index = Tree.Index
type alias Tree a = Tree.Tree a

type Crumb a =
    Crumb Index a (Array (Tree a))

type alias Crumbs a = List (Crumb a)

type FocusTree a = FocusTree (Tree a) (Crumbs a)


unfocus : FocusTree a -> Tree a
unfocus ((FocusTree tree crumbs) as focus) =
    case goUp focus of
        Nothing ->
            tree

        Just parentFocus ->
            unfocus parentFocus


getCurrentValue : FocusTree a -> a
getCurrentValue (FocusTree tree _) =
    case Tree.getValue tree of
        Nothing ->
            Debug.crash "Couldn't get the current value of the tree. This shouldn't occur when used through this module's public API. Please report a bug."

        Just value ->
            value


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
            Empty ->
                (0, FocusTree childTree crumbs)

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
goDown index (FocusTree tree crumbs) =
  case tree of
      Empty ->
          Nothing

      Node value subtrees ->
          Tree.getSubtreeAt subtrees index `andThen` \ (subtree, otherSubtrees) ->
              Just <| FocusTree subtree (Crumb index value otherSubtrees :: crumbs)


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


traverseDownwards : List Index -> FocusTree a -> Maybe (FocusTree a)
traverseDownwards indices focusTree =
    let
        go index maybeTree =
            maybeTree `andThen` \tree ->
                goDown index tree
    in
        List.foldl go (Just focusTree) indices


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
