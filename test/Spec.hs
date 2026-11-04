module Main (main) where

import System.Directory (createDirectoryIfMissing, getTemporaryDirectory,
                         removeDirectoryRecursive)
import System.FilePath ((</>))
import Test.Hspec

import QuestFiles

-- 🗂️ Make a folder with a file for each quest, in this order.
-- 依頼ごとにファイルを作ったフォルダーを、この順で用意する
withQuestFolder :: (FilePath -> IO a) -> IO a
withQuestFolder action = do
  tmp <- getTemporaryDirectory
  let dir = tmp </> "modern-book-quests"
  createDirectoryIfMissing True dir
  mapM_ (\(file, quest) -> writeFile (dir </> file) (quest <> "\n"))
    [ ("3-tower.txt", "climb the tower")
    , ("1-cave.txt", "explore the cave")
    , ("2-forest.txt", "find the herb")
    ]
  result <- action dir
  removeDirectoryRecursive dir
  pure result

main :: IO ()
main = hspec $ describe "QuestFiles" $ do
  -- 名前の順に読む（どの OS でも）
  it "reads the quests in name order" $ do
    quests <- withQuestFolder loadQuests
    quests `shouldBe`
      ["explore the cave", "find the herb", "climb the tower"]
  -- The draft: it trusts the order listDirectory gives.
  -- 下書き：listDirectory の順番を信じている
  it "the draft reads the quests in name order (it may not!)" $ do
    quests <- withQuestFolder loadQuestsDraft
    quests `shouldBe`
      ["explore the cave", "find the herb", "climb the tower"]
