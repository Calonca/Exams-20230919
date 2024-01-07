data Slist a = Slist Int [a] deriving (Show, Eq)

instance Foldable Slist where
  foldr f z (Slist _ xs) = foldr f z xs

instance Functor Slist where
  fmap f (Slist l xs) = Slist l (fmap f xs)

instance Applicative Slist where
  -- pure :: a -> f a
  pure :: a -> Slist a
  pure xs = Slist 1 (pure xs)
  (<*>) :: Slist (a -> b) -> Slist a -> Slist b
  (Slist lf fs) <*> (Slist la a) = Slist (lf*la) (fs <*> a)

makeSlist v = Slist (length v) v

-- instance Monad Slist where
--   sl@(Slist l xs) >>= f = makeSlist ( concatMap ((\(Slist _ xs1) -> xs1) . f) xs )
--   -- xs is of type [a]

instance MonadFail Slist where
  fail _ = Slist 0 []

instance Monad Slist where
  (Slist n xs) >>= f = makeSlist (xs >>= f1)
    where f1 = (\(Slist _ xs1) -> xs1) . f -- Function from a -> Slist b -> [b]

-- (foldr ++ (map a fs))
main :: IO ()
main = do
  let myList = Slist 5 [1, 2, 3, 4, 5]
  print myList
  print $ fmap (1 +) myList
