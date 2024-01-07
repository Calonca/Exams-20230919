-- Consider a Tvtl (two-values/two-lists) data structure, which can store either two values of a given type, or
-- two lists of the same type.
-- Define the Tvtl data structure, and make it an instance of Functor, Foldable, and Applicative.

data Tvtl a = Tv a a | Tl [a] [a] deriving(Show)

instance Functor Tvtl where
    fmap f (Tv x y) = Tv (f x) (f y)
    fmap f (Tl xs ys) = Tl (fmap f xs) (fmap f ys)

instance Foldable Tvtl where
    foldr f i (Tv x y) = f y (f x i)
    foldr f i (Tl x y) = foldr f i (x ++ y) 

instance Applicative Tvtl where
    
    

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
