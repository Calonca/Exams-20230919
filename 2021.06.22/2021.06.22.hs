data BTT a = DBranch a (BTT a) (BTT a) | TBranch a (BTT a) (BTT a) (BTT a) | Nil

aTree = TBranch 1 (DBranch 2 Nil Nil) Nil (DBranch 4 Nil Nil)

-- print tree
printTree :: Show a => BTT a -> Int -> Int -> IO ()
printTree Nil dist right = do
  let s = replicate dist ' '
  let r = replicate right '|'
  putStrLn (s ++ "N" ++ r)
printTree (DBranch v l r) dist right = do
  let s = replicate dist ' '
  let rs = replicate right '|'
  putStrLn (s ++ show v ++ rs)
  putStrLn (s ++ "|\\")
  printTree l dist 1
  printTree r (dist + 1) 0
printTree (TBranch v l m r) dist right = do
  let s = replicate dist ' '
  let rs = replicate right '|'
  putStrLn (s ++ show v ++ rs)
  putStrLn (s ++ "|\\\\")
  printTree l dist 2
  printTree m (dist + 1) 1
  printTree r (dist + 2) 0

instance Functor BTT where
  fmap f Nil = Nil
  fmap f (DBranch v l r) = DBranch (f v) (fmap f l) (fmap f r)
  fmap f (TBranch v l m r) = TBranch (f v) (fmap f l) (fmap f m) (fmap f r)


instance Foldable BTT where
  foldr f z Nil = z
  foldr f z (DBranch v l r) = f v (foldr f (foldr f z r) l)
  foldr f z (TBranch v l m r) = f v (foldr f (foldr f (foldr f z r) m) l)

(<++>):: BTT a -> BTT a -> BTT a
l <++> Nil = l
Nil <++> r = r
(DBranch lv ll lr) <++> r = TBranch lv ll lr r
l <++> (DBranch lv ll lr)= TBranch lv l ll lr
(TBranch v1 l1 m1 r1) <++> t2@(TBranch v2 l2 m2 r2) = TBranch v1 l1 m1 (r1 <++> t2 )

instance Applicative BTT where
  pure a = DBranch a Nil Nil
  DBranch vf l r <*> t2 = fmap vf t2
  TBranch vf l m r <*> t2 = fmap vf t2

main :: IO ()
main = do
  print "Hello, World!"
  -- Print tree
  printTree aTree 0 0
  -- Print tree after map
  let a = fmap [(+ 1) (- 1)] aTree
  printTree a 0 0
  print (foldr (*) 2 a)
