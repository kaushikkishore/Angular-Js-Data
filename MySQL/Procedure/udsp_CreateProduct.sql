/*									
Name			:	udsp_CreateProduct								
Description		: 	Creates a Product								
Author			: 	Kaushik								
									
Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            19-DEC-14		Kaushik						
---------------------------------------------------------------------------									
Call	udsp_CreateProduct
(
	'My Topbar',
	'1',
	'{"Message": "Join Our Webinar", "LinkText": "Click Here", "LinkURL": "https://leadsquared.com", "BarColor": "eb593c", "TextColor": "ffffff", "ButtonColor": "000000", "ButtonTextColor": "ffffff"}',
	'{"EntireWeb":true,"ExcludeUrls":[],"IncludeUrls":[]}',
	'{"StartDate": "2014-10-17T10:09:24.167Z", "EndDate": "2014-10-17T10:09:24.167Z", "ExcludeDays": []}',
	'0',
	'1',
	'a1826ffdec620b999a14c133610a19ad7d88117e22ff2a541a0b22fdfb6c7d8b'
)								
*/									
									
									
									
DROP PROCEDURE IF EXISTS udsp_CreateProduct;									
DELIMITER //									
CREATE PROCEDURE udsp_CreateProduct									
(	
	var_RequestorId			VARCHAR(100)			,
	var_Name			  	NVARCHAR(100)			,			
	var_Code			  	INT(11)	    			,			 
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
	DECLARE var_ProductId				varchar(36);	
	DECLARE error_InvalidInputs         CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
			RESIGNAL ;
		END;
									

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------								
	SET	var_RequestorId			= IFNULL(var_RequestorId,'');
	SET	var_Name				= IFNULL(var_Name,'');
	SET	var_Code				= IFNULL(var_Code,0);
	SET	var_Description			= IFNULL(var_Description,'');
	SET	var_ReleaseDate 		= IFNULL(var_ReleaseDate,'');
	SET	var_Cost	    		= IFNULL(var_Cost,'');
	SET	var_Price				= IFNULL(var_Price,'');	
	SET	var_Category 			= IFNULL(var_Category,'');
	SET	var_Tag	    			= IFNULL(var_Tag,'');
	SET	var_ImageUrl			= IFNULL(var_ImageUrl,'');
		    
	SET var_ProductId					= UUID();

	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	
	-- a) Mandatory Check
	IF(var_Name = '') THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Fields are not provided. `Name` is mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;								
									
	-- --------------------------------------------------------------------------								
	-- #4 :: Create Record								
	-- --------------------------------------------------------------------------								
	START TRANSACTION;								
									
		INSERT INTO Product_Base							
		(ProductId		, Name		, Code		, Description		, ReleaseDate		, StatusCode	, StatusReason	, Cost		, Price		  , Category		, Tag		, ImageUrl		, CreatedOn			, ModifiedOn        )	VALUES							
		(var_ProductId	, var_Name	, var_Code	, var_Description	, var_ReleaseDate	, 0				, 0				, var_Cost	, var_Price	  , var_Category	, var_Tag   , var_ImageUrl	, UTC_TIMESTAMP()	, UTC_TIMESTAMP() 	);							
									
	COMMIT;								
	
	SELECT var_ProductId AS TransactionID;								
END //									
DELIMITER ;									
