gzip :: [[a]] -> [[a]]
gzip xs
  | any null xs = []
  | otherwise = map head xs : gzip (map tail xs)

-- gzip :: [[a]] -> [[a]]
-- gzip [] = []
-- gzip xs@(x:rest) = 
--   foldl f [[xa] | xa <- x] rest
--   where f = \acc x1 -> [fst z ++ [snd z] | z <- zip acc x1]

-- holdTwoGreates x acc@(fst,scd) = if x > scd then (if x > fst then (x,fst) else (fst,x)) else (fst,scd)
holdTwoGreates x (fst,scd) | x > fst = (x,fst)
holdTwoGreates x (fst,scd) | x > scd = (fst,x)
holdTwoGreates x a = a

orderTuple (x1,x2) | x2 > x1 = (x2,x1)
orderTuple a = a

sumTwoGreatest xs =
  [let (f,s) = f1 z in f+s | z <- gzip xs]
  where f1 (x1:x2:rest) = foldr holdTwoGreates (orderTuple (x1,x2)) rest


main :: IO ()
main = do
  print (gzip [[1,8,3],[4,5,6],[7,8,9],[10,2,3]])
  print (sumTwoGreatest [[1,8,3],[4,5,6],[7,8,9],[10,2,3]])