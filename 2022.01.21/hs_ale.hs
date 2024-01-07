data Tvtl a = Tv a a | Tl [a] [a] deriving Show

instance Functor Tvtl where
    fmap f (Tv a b) = Tv (f a) (f b)
    fmap f (Tl a b) = Tl (fmap f a) (fmap f b)

instance Foldable Tvtl where
    foldr f z (Tv a b) = f a (f b z)
    foldr f z (Tl a b) = foldr f (foldr f z b) a

instance Applicative Tvtl where
    pure x = Tl [x] []
    -- (Tv f1 f2) <*> (Tv a b) = Tl [f1 a,f2 a] [f1 b,f2 b]
    (Tv f1 f2) <*> (Tv a b) = Tl [f1] [f2] <*> Tl [a] [b]
    (Tv f1 f2) <*> (Tl a b) = Tl [f1] [f2] <*> Tl a b
    (Tl f1 f2) <*> (Tv a b) = Tl f1 f2 <*> Tl [a] [b]
    (Tl fsA fsB) <*> (Tl a b) = Tl (fs <*> a) (fs <*> b)
        where fs = fsA ++ fsB

-- (Tv x y) +++ (Tv z w) = Tl [x,z] [y,w]
-- (Tv x y) +++ (Tl l r) = Tl (x:l) (y:r)
-- (Tl l r) +++ (Tv x y) = Tl (l++[x]) (r++[y])
-- (Tl l r) +++ (Tl x y) = Tl (l++x) (r++y)
-- tvtlconcat t = foldr (+++) (Tl [][]) t
-- tvtlcmap f t = tvtlconcat $ fmap f t

-- instance Applicative Tvtl where
--     pure x = Tl [x] []
--     x <*> y = tvtlcmap (\f -> fmap f y) x

main :: IO ()
main = do
    -- Test Functor instance
    let t1 = fmap (+1) (Tv 2 3)
    putStrLn $ "Functor test: " ++ show t1  -- Output: Functor test: Tv 3 4

    -- Test Foldable instance
    let t2 = foldr (+) 0 (Tl [1, 2, 3] [4, 5, 6])
    putStrLn $ "Foldable test: " ++ show t2  -- Output: Foldable test: 21

    -- Test Applicative instance
    let t3 = Tv (* 10) (+ 1) <*> Tl [2,1] [0]
    putStrLn $ "Applicative test: " ++ show t3  -- Output: Applicative test: Tl [20,10,3,2] [0,1]
