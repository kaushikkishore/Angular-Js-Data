/*
Name		: udsp_RetrieveProducts
Description	: Retrieves Products
Author		: Kaushik

Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            20-DEC-14		Kaushik											
---------------------------------------------------------------------------		
	
Call	udsp_RetrieveProducts
(
	'c4bf7bf1817bd730b240a3d5b47378f7dc3c51c67665915daf1f6052b21875c5',
	'',
	'',
	'',
	'',
	'',
	''
)

*/									
									
DROP PROCEDURE IF EXISTS udsp_RetrieveProducts;									
DELIMITER //									
CREATE PROCEDURE udsp_RetrieveProducts									
(	
	var_RequestorId			varchar(100)     ,								
	var_ColumnLookupName	nvarchar(100)	,
	var_ColumnLookupValue	nvarchar(1000)	,
	var_SearchKey			nvarchar(100)	,
	var_StatusCode			int				,
	var_OrderBy				nvarchar(100)	,
	var_Limit				varchar(20)		
)									
BEGIN									
	-- --------------------------------------------------------------------------
	-- #1 :: Declaration
	-- --------------------------------------------------------------------------
	DECLARE error_InvalidInputs                 CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLSTATE '22001' 								
	BEGIN								
		ROLLBACK;							
		SIGNAL SQLSTATE '22001';      							
	END;

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------	
	SET var_RequestorId 		= IFNULL(var_RequestorId,'');
	SET	var_ColumnLookupName	= IFNULL(var_ColumnLookupName,'');
	SET	var_ColumnLookupValue	= IFNULL(var_ColumnLookupValue,'');

	SET	var_SearchKey			= IFNULL(var_SearchKey,'');
	SET	var_StatusCode			= IFNULL(var_StatusCode,'-1');

	SET	var_OrderBy				= IFNULL(var_OrderBy,'');
	SET	var_Limit				= IFNULL(var_Limit,'');
	SET var_AuthToken			= IFNULL(var_AuthToken,'');

	SET var_OrderBy = CASE     
      WHEN var_OrderBy LIKE 'ModifiedByName%' THEN var_OrderBy
      WHEN var_OrderBy = '' THEN 'W.CreatedOn DESC'
      ELSE CONCAT('W.',var_OrderBy)
     END;	
	
	IF var_Limit	= '' THEN 
		SET var_Limit		= ' 0,25 ';
	END IF;

	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	-- a) Mandatory Check
	IF(var_AuthToken = '') THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Field(s) are not provided. `var_AuthToken` is mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;
		
	-- --------------------------------------------------------------------------								
	-- #4 :: Prepare Statement
	-- --------------------------------------------------------------------------	
	SET @var_SQL_Select			= '';
		
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	SELECT 	SQL_CALC_FOUND_ROWS W.*, '); 
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'				TRIM(Concat(IFNULL(U_M.FirstName,''''), '' '', IFNULL(U_M.LastName,''''))) ModifiedByName,');
    SET @var_SQL_Select = CONCAT(@var_SQL_Select,'			    TRIM(Concat(IFNULL(U_O.FirstName,''''), '' '', IFNULL(U_O.LastName,''''))) OwnerName,'); 
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'				TRIM(Concat(IFNULL(U_C.FirstName,''''), '' '', IFNULL(U_C.LastName,''''))) CreatedByName');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	FROM		WebWidget_Base W ');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'				LEFT JOIN User_Base U_M ON W.ModifiedBy = U_M.UserId ');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'				LEFT JOIN User_Base U_O ON W.CreatedBy  = U_O.UserId ');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'				LEFT JOIN User_Base U_C ON W.CreatedBy  = U_C.UserId ');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	WHERE       1=1 ');


	
	IF var_ColumnLookupName <> '' THEN
		IF var_ColumnLookupName = 'Type' AND var_ColumnLookupValue='0' THEN
			SET @var_SQL_Select = CONCAT(@var_SQL_Select,'');
		ELSE
			SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	AND		W.',var_ColumnLookupName,' = ''',var_ColumnLookupValue,''' ');
		END IF;
	END IF;

	IF var_SearchKey <> '' THEN
		SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	AND		Concat(W.Name) LIKE ''%',var_SearchKey,'%''');
	END IF;

	
	IF var_StatusCode <> -1 THEN 
		SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	AND		W.StatusCode = ',var_StatusCode,' ' );
	END IF;

	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	ORDER BY	',var_OrderBy, ' ');
	SET @var_SQL_Select = CONCAT(@var_SQL_Select,'	LIMIT		',var_Limit, ' ');

	-- SELECT @var_SQL_Select;
	-- --------------------------------------------------------------------------								
	-- #5 :: Execute Statement
	-- --------------------------------------------------------------------------								
    PREPARE stmt1 FROM @var_SQL_Select;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
	
	SELECT FOUND_ROWS() AS TotalRows; 	

END //									
DELIMITER ;									
