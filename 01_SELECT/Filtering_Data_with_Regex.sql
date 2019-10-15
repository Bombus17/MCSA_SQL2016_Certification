USE AdventureWorks2017
GO

/* ----------------------------------------------------------------
Purpose: Find characters in text

Prerequisite: run CREATE RegexTest table script


TODO: Finalise this script

----------------------------------------------------------------*/

SELECT * FROM RegexTest;

/* Find records that are a single letter
--------------------------------------------------------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[A-Z]';

/* could use LEN but this would also return digits 
-------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE len(AlphaCol) = 1; 

/* Similarly,find records that begin with a digit
--------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[0-9]%'

/* By adding a second range, we build up the expression
-- here we return 2 character records 
---------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[A-Z][A-Z]';


/* Any characters from A-Z 
-------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[A-Z]%'; 

/* Regex to Find Specific Text Pattern
  for example first character = W and second h or w
 --------------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[W][HE]%' ;

/* Find Specific Text Patterns
------------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '%[T][-]%'; 


/* Each range specifies a search condition
Begins with T, followed by any combination of letters after that
And then require R
Followed by t
Followed by any other character %.
---------------------------------------------------*/

SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[T]%[R][T]%';  


/* Regex to Find Upper Case or Lower Case Characters 
	words that are capitalised in the sentence
	*/
SELECT *
FROM RegexTest
WHERE AlphaCol COLLATE Latin1_General_BIN LIKE '[a-z]%[A-Z]%'  

/* Regex to Find Upper Case or Lower Case Characters */
SELECT *
FROM RegexTest
WHERE AlphaCol COLLATE Latin1_General_BIN LIKE '[A-Za-z]%[A-Z]%'   

/* SPECIAL CHARACTERS 
-------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '%["]'
 
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '%[?]'

/* spaces are considered special characters
--------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol  LIKE '[^A-Z0-9]%[^A-Z0-9]%[^A-Z0-9]' 


/* punctuation characters 
------------------------*/ 
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '%[,.!?;;]%'   
 
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '%[,.!?;;][ ]%[A-Z]%'   

/* USING THE not ^ character where there are no matches

----------------------------------------------------*/
SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[^A-Z]%'
  

/* REGEX TO EXCLUDE NUMBERS AND LETTERS 
------------------------------------------*/

SELECT *
FROM RegexTest
WHERE AlphaCol LIKE '[^A-Z0-9]%'    

/* REGEX TO FIND TEXT PATTERNS NOT INCLUDING CHARACTERS 
sentences that start with any alphabetic character, 
end with any alphabetic character or period, and have a special character within them
*/
SELECT *
FROM RegexTest
WHERE AlphaCol  LIKE '[A-Z]%[^A-Z0-9 ]%[A-Z.]'


