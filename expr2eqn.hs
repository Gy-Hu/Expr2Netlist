import Text.Parsec
import Text.Parsec.String (Parser)
import Text.Parsec.Language (emptyDef)
import qualified Text.Parsec.Token as Token
import Data.List (nub, sort)
import Data.BoolSimplifier
import System.IO

-- Define a basic lexer
lexer = Token.makeTokenParser emptyDef

-- Use the lexer to define parsers for parentheses and identifiers
parens = Token.parens lexer
brackets = Token.brackets lexer
identifier = Token.identifier lexer
whiteSpace = Token.whiteSpace lexer
integer = Token.integer lexer

-- Define our data structures for the parsed expression
data Expr = Term String 
          | UnaryOp Expr
          | LogicalNot Expr
          | BitAnd Expr Expr 
          | BitOr Expr Expr
          | BitXor Expr Expr
          | LogicalAnd Expr Expr 
          | LogicalOr Expr Expr 
    deriving (Show)

-- Parser for constants
constant :: Parser Expr
constant = do
    size <- optionMaybe (try (fromIntegral <$> integer <* char '\''))
    base <- oneOf "bBdDhH"
    value <- case base of
        'b' -> many1 (oneOf "01xXzZ")
        'B' -> many1 (oneOf "01xXzZ")
        'd' -> many1 digit
        'D' -> many1 digit
        'h' -> many1 (oneOf "0123456789abcdefABCDEFxXzZ")
        'H' -> many1 (oneOf "0123456789abcdefABCDEFxXzZ")
    return $ Term (maybe "" (\s -> show s ++ "'") size ++ [base] ++ value)

-- Parser for terms
term :: Parser Expr
term = (try constant) <|> (Term <$> identifier) <|> parens expr

-- Highest precedence: !, ~
unary :: Parser Expr
unary = (try (char '!' *> (LogicalNot <$> unary)))
    <|> (try (char '~' *> (UnaryOp <$> unary)))
    <|> term

-- Bitwise operations: &, |, ^, etc.

bitAnd :: Parser Expr
bitAnd = chainl1 unary (whiteSpace *> try (char '&' <* notFollowedBy (char '&')) *> whiteSpace *> return BitAnd)

bitOr :: Parser Expr
bitOr = chainl1 bitAnd (whiteSpace *> try (char '|' <* notFollowedBy (char '|')) *> whiteSpace *> return BitOr)

bitXor :: Parser Expr
bitXor = chainl1 bitOr (whiteSpace *> (char '^') *> whiteSpace *> return BitXor)

-- Logical operations: &&, ||
logAnd :: Parser Expr
logAnd = chainl1 bitXor (whiteSpace *> try (string "&&") *> whiteSpace *> return LogicalAnd)

logOr :: Parser Expr
logOr = chainl1 logAnd (whiteSpace *> try (string "||") *> whiteSpace *> return LogicalOr)

-- The main expression parser
expr :: Parser Expr
expr = logOr

-- Test function
parseTestExpr :: String -> Either ParseError Expr
parseTestExpr = parse (whiteSpace *> expr <* eof) ""

-- Function to convert Expr to a tree-like string representation
exprToTree :: Expr -> String
exprToTree = go 0
  where
    go indent e = case e of
      Term t -> replicate indent ' ' ++ t ++ "\n"
      UnaryOp e1 -> replicate indent ' ' ++ "~\n" ++ go (indent + 2) e1
      LogicalNot e1 -> replicate indent ' ' ++ "!\n" ++ go (indent + 2) e1
      BitAnd e1 e2 -> binaryOpToTree indent "&" e1 e2
      BitOr e1 e2 -> binaryOpToTree indent "|" e1 e2
      BitXor e1 e2 -> binaryOpToTree indent "^" e1 e2
      LogicalAnd e1 e2 -> binaryOpToTree indent "&&" e1 e2
      LogicalOr e1 e2 -> binaryOpToTree indent "||" e1 e2

    binaryOpToTree indent op e1 e2 =
      replicate indent ' ' ++ op ++ "\n" ++ go (indent + 2) e1 ++ go (indent + 2) e2

-- Function to convert and print the EQN for a given string input
printEqn :: String -> IO ()
printEqn input = case parseTestExpr input of
  Left err -> putStrLn $ "Error: " ++ show err
  Right expr -> do
    let vars = nub $ sort $ extractVars expr
    putStrLn $ "INORDER = " ++ unwords vars ++ ";"
    putStrLn "OUTORDER = F;"
    putStrLn $ "F = " ++ exprToEqn expr ++ ";"

-- Test function to print the tree representation
printExprTree :: String -> IO ()
printExprTree input = case parseTestExpr input of
  Left err -> putStrLn $ "Error: " ++ show err
  Right expr -> putStrLn $ exprToTree expr

-- Extracts all variable names from an expression
extractVars :: Expr -> [String]
extractVars (Term t) = [t]
extractVars (UnaryOp e) = extractVars e
extractVars (LogicalNot e) = extractVars e
extractVars (BitAnd e1 e2) = extractVars e1 ++ extractVars e2
extractVars (BitOr e1 e2) = extractVars e1 ++ extractVars e2
extractVars (BitXor e1 e2) = extractVars e1 ++ extractVars e2
extractVars (LogicalAnd e1 e2) = extractVars e1 ++ extractVars e2
extractVars (LogicalOr e1 e2) = extractVars e1 ++ extractVars e2

-- Convert an Expr to its Synopsys EQN representation
exprToEqn :: Expr -> String
exprToEqn (Term t) = t
exprToEqn (UnaryOp e) = "!(" ++ exprToEqn e ++ ")"
exprToEqn (LogicalNot e) = "!(" ++ exprToEqn e ++ ")"
exprToEqn (BitAnd e1 e2) = exprToEqn e1 ++ " * " ++ exprToEqn e2
exprToEqn (BitOr e1 e2) = exprToEqn e1 ++ " + " ++ exprToEqn e2
exprToEqn (BitXor e1 e2) = "XOR(" ++ exprToEqn e1 ++ ", " ++ exprToEqn e2 ++ ")"
exprToEqn (LogicalAnd e1 e2) = exprToEqn e1 ++ " * " ++ exprToEqn e2
exprToEqn (LogicalOr e1 e2) = exprToEqn e1 ++ " + " ++ exprToEqn e2

-- Function to save the EQN to a .eqn text file
saveEqnToFile :: String -> FilePath -> IO ()
saveEqnToFile input filePath = case parseTestExpr input of
  Left err -> putStrLn $ "Error: " ++ show err
  Right expr -> do
    let vars = nub $ sort $ extractVars expr
    let eqn = "INORDER = " ++ unwords vars ++ ";\nOUTORDER = F;\nF = " ++ exprToEqn expr ++ ";\n"
    writeFile filePath eqn

main :: IO ()
main = do
    putStrLn "Enter the expression:"
    input <- getLine
    putStrLn "Expression tree:"
    printExprTree input
    putStrLn "EQN:"
    printEqn input
    putStrLn "Enter the output file name (e.g., output.eqn):"
    outputFile <- getLine
    saveEqnToFile input outputFile
    putStrLn $ "EQN saved to " ++ outputFile