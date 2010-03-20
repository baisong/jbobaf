module Jbobaf.Internals where
 import List (find, findIndices)
 import Monad (liftM2)
 import Jbobaf.Vlatai (isC)

 infixr 5 ~:, ~~, ~:~
 infixr 0 ?:, :?

 (~:) :: Monad m => a -> m [a] -> m [a]
 a ~: xs = xs >>= return . (a :)

 (~~) :: Monad m => m [a] -> m [a] -> m [a]
 (~~) = liftM2 (++)

 (~:~) :: Monad m => m a -> m [a] -> m [a]
 (~:~) = liftM2 (:)

 data TernaryBranch a = a :? a deriving (Eq, Ord, Read, Show, Bounded)

 instance Functor TernaryBranch where fmap f (x :? y) = f x :? f y

 (?:) :: Bool -> TernaryBranch a -> a
 True ?: (y :? _) = y
 False ?: (_ :? z) = z

 findCC :: String -> Maybe Int
 findCC str = find (\i -> isC (str !! (i+1)) || toLower (str !! (i+1)) == 'y'
  && isC (str !! (i+2))) $ findIndices isC str

 findLa :: String -> Maybe Int
 -- How should this handle commas after "la" et alii?
 findLa = fla 0 False . map toLower
  where fla _ _ [] = Nothing
	fla pos False ('l':'a':'\'':'i':c:xs) =
	 if not (isV c) && c /= '\\'' then Just (pos+4)
	 else fla (pos+5) False xs
	fla pos False ('l':'a':'i':c:xs) =
	 if not (isV c) && c /= '\\'' then Just (pos+3)
	 else fla (pos+4) False xs
	fla pos False ('l':'a':c:xs) =
	 if not (isV c) && c /= '\\'' then Just (pos+2)
	 else fla (pos+3) False xs
	fla pos False ('d':'o':'i':c:xs) =
	 if not (isV c) && c /= '\\'' then Just (pos+3)
	 else fla (pos+4) False xs
	fla pos _ (c:xs) = fla (pos+1) (isC c) xs
