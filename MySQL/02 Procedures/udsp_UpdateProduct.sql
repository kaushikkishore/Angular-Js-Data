/*									
Name		: udsp_UpdateProduct								
Description	: Updates a Product								
Author		: Kaushik								
									
Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            20-DEC-14		Kaushik	
											
---------------------------------------------------------------------------									
Call	udsp_UpdateProduct
(
	'',						
	'382e88cd-882d-11e4-a71f-b888e3eaff25',
	'Tata Tea',			
	'',			 
	'',			
	NULL,			
	'',			
	'',			
	'',
	'',
	''   
)

*/									
									
DROP PROCEDURE IF EXISTS udsp_UpdateProduct;									
DELIMITER //									
CREATE PROCEDURE udsp_UpdateProduct									
(		
	var_RequestorId			VARCHAR(100)			,						
	var_ProductId			VARCHAR(36)				,
	var_Name			  	NVARCHAR(100)			,			
	var_Code			  	VARCHAR(36)   			,			 
	var_Description		  	TEXT CHARACTER SET utf8 ,			
	var_ReleaseDate	  		DATETIME				,			
	var_Cost   				NVARCHAR(100)			,			
	var_Price	      		NVARCHAR(100)			,			
	var_Category      		NVARCHAR(255)       	,
	var_Tag		  			NVARCHAR(255)			,
	var_ImageUrl			NVARCHAR(255)		      	
)									
BEGIN									
	-- --------------------------------------------------------------------------
	-- #1 :: Declaration
	-- --------------------------------------------------------------------------
	
	DECLARE error_InvalidInputs                 CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL ;
	END;

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------
	SET var_ProductId	= IFNULL(var_ProductId,'');
	SET var_Name		= IFNULL(var_Name,'');
	SET var_Code		= IFNULL(var_Code,'');
	SET var_Description	= IFNULL(var_Description,'');
	SET var_ReleaseDate	= IFNULL(var_ReleaseDate,'0001-01-01 00:00:01');
	SET var_Cost   		= IFNULL(var_Cost,'');
	SET var_Price	    = IFNULL(var_Price,'');
	SET	var_Category    = IFNULL(var_Category,'');
	SET var_Tag		  	= IFNULL(var_Tag,'');
	SET	var_ImageUrl	= IFNULL(var_ImageUrl,'');
	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	-- a) Mandatory Fields

	IF(TRIM(var_ProductId) = '' ) THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Fields are not provided. `ProductId` is mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;


	-- --------------------------------------------------------------------------								
	-- #4 :: Update Record								
	-- --------------------------------------------------------------------------								
	START TRANSACTION;								

		SET @var_RowsUpdated = 0;
									
		UPDATE	Product_Base
		SET		Name				= IF(var_Name				= ''						, Name			, var_Name			),
				Code				= IF(var_Code				= ''						, Code			, var_Code			),
				Description			= IF(var_Description		= ''						, Description	, var_Description	),
				ReleaseDate			= IF(var_ReleaseDate		= '0001-01-01 00:00:01'		, ReleaseDate	, var_ReleaseDate	),
				Cost				= IF(var_Cost				= ''						, Cost			, var_Cost			),
				Price				= IF(var_Price				= ''						, Price			, var_Price			),
				Category			= IF(var_Category			= ''						, Category		, var_Category		),
				Tag					= IF(var_Tag				= ''						, Tag			, var_Tag			),
				ImageUrl			= IF(var_ImageUrl			= ''						, ImageUrl		, var_ImageUrl		),
				ModifiedOn			= UTC_TIMESTAMP()																			
		
		WHERE	ProductId				= var_ProductId;
	
		SELECT ROW_COUNT() INTO @var_RowsUpdated;

	COMMIT;									

	SELECT @var_RowsUpdated AffectedRows;
						
END //									
DELIMITER ;									
