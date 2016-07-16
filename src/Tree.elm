module Tree exposing (Index, Tree(..), getValue, leaf, getSubtreeAt)

import Array exposing (Array)
import Maybe exposing (andThen)

type alias Index = Int

type Tree a
    = Empty
    | Node a (Array (Tree a))


getValue : Tree a -> Maybe a
getValue tree =
    case tree of
        Empty ->
            Nothing
        
        Node val _ ->
            Just val


leaf : a -> Tree a
leaf value =
    Node value Array.empty


getSubtreeAt : Array (Tree a) -> Index -> Maybe (Tree a, Array (Tree a))
getSubtreeAt subtrees index =
    let
        maybeTree =
            Array.get index subtrees

        leftTrees =
            Array.slice 0 index subtrees

        rightTrees =
            Array.slice (index+1) (Array.length subtrees) subtrees

        otherTrees =
            Array.append leftTrees rightTrees
    in
        maybeTree `andThen` \tree -> Just (tree, otherTrees)
