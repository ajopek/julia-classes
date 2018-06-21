module Kolos(Student, Score, StudentWithScores, StudentWithScores') where
    import Text.Read
    import Data.List
    import Data.Map
    data Student = Student {id :: Int, name :: String, dateOfBirth :: String} deriving Show
    data Score = Score {studentId :: Int, course1Score :: Int, course2Score :: Int, course3Score :: Int} deriving Show 
    data StudentWithScores = StudentWithScores {swsid :: Int, 
                                                swsname :: String,
                                                swsdateOfBirth :: String, 
                                                swscourse1Score :: Int,
                                                swscourse2Score :: Int,
                                                swscourse3Score :: Int}
    data StudentWithScores' = StudentWithScores' Int String String Int Int Int
    data Maybe' a = Just' a | Nothing'

    func ::  Maybe' Int -> Maybe' Int -> Bool
    func (Just' x) (Just' y) = x == y
    func (Nothing') (_) = False
    func (_) (Nothing') = False

    instance Show StudentWithScores' where
        show (StudentWithScores' id name date score1 score2 score3) = show(id) 
                                                                        ++ name 
                                                                        ++ date 
                                                                        ++ show(score1) 
                                                                        ++ show(score2) 
                                                                        ++ show(score3) 
                                                                 
    instance Eq StudentWithScores' where
        (==) (StudentWithScores' id1 name1 date1 _ _ _) (StudentWithScores' id2 name2 date2 _ _ _) = id1 == id2 && name1 == name2 && date1 == date2

    instance Eq StudentWithScores where
        (==) x y = swsname(x) == swsname(y)

    
    sortByDate :: [Student] -> [Student]
    sortByDate = sortBy cmp
        where cmp (Student _ _ date1) (Student _ _ date2) = compare (readMaybe date1 :: Maybe Int) (readMaybe date2 :: Maybe Int)
    
    sortByScoreAndId :: [StudentWithScores'] -> [StudentWithScores']
    sortByScoreAndId = sortBy cmp
        where 
            cmp (StudentWithScores' id1 _ _ score1 _ _) (StudentWithScores' id2 _ _ score2 _ _) 
                | score1 == score2  = compare id1 id2
                | otherwise = compare score1 score2


    toStudentWithScores :: Student -> Score -> Maybe StudentWithScores'
    toStudentWithScores (Student id name date) (Score id2 s1 s2 s3) 
            | id == id2 = Just (StudentWithScores' id name date s1 s2 s3)
            | otherwise = Nothing

    findById :: [Score] -> Int -> [Score] 
    findById scores id = Data.List.filter ffunc scores
            where ffunc (Score id1 _ _ _) = id == id1

    --reduceBy :: ([a] -> Score -> [a]) -> [Score] -> [a]

    class (Ord a) => Id a where
        toInt :: a -> Int
        
    class HasId a where
      getId :: (Id b) => a -> b
    
    class Repository a where
      insert :: (HasId b) => b -> a -> a
      delete :: (Id c)          => c -> a -> a
      get    :: (HasId b, Id c) => c -> a -> Maybe b
      update :: (HasId b, Id c) => c -> b -> a     
      count  :: a -> Int
    
    data InMemoryRepository k v = InMemoryRepository (Map k v)
    
    instance Repository (InMemoryRepository k v) where
        insert :: v -> (InMemoryRepository k v)
        insert val   (InMemoryRepository m) = InMemoryRepository (Data.Map.insert (getId val) val m)
        delete key   (InMemoryRepository m) = InMemoryRepository (Data.Map.delete key m)
        get    key   (InMemoryRepository m) = Data.Map.lookup key m
        update key val (InMemoryRepository m) = InMemoryRepository (Data.Map.alter f key m)
            where
                f (Just a) = Just val
                f Nothing  = Just val
        count (InMemoryRepository m) = Data.Map.size m
      

    instance Applicative Maybe where
        pure = Just
        Nothing <*> _ = Nothing
        (Just f) <*> w = fmap f w
    
    instance Functor Maybe where
        fmap f (Just x) = Just (f x)
        fmap f Nothing = Nothing