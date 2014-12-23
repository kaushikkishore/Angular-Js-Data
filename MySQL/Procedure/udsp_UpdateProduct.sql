/*									
Name		: udsp_UpdateWebWidget								
Description	: Updates a Widget								
Author		: CRN								
									
Modification Log: Change									
---------------------------------------------------------------------------									
Description                  Date			Changed By						
Created procedure            23-Oct-14		CRN	
											
---------------------------------------------------------------------------									
Call	udsp_UpdateWebWidget
(
  'a1826ffdec620b999a14c133610a19ad7d88117e22ff2a541a0b22fdfb6c7d8b',
	'04d95208-5eaa-11e4-8e7d-22000b500d7b',
	'Topbar 01-01',
	'',
	'',
	'',
	'',
	'',
	''
)

*/									
									
DROP PROCEDURE IF EXISTS udsp_UpdateWebWidget;									
DELIMITER //									
CREATE PROCEDURE udsp_UpdateWebWidget									
(		
	var_AuthToken		  varchar(64)	,						
	var_WidgetId		  varchar(36)   ,
	var_Name			  nvarchar(100)	,			
	var_Type			  int(11)	    ,			 
	var_Content			  text CHARACTER SET utf8	        ,			
	var_DisplayLocation	  text CHARACTER SET utf8	,			
	var_DisplayDuration   varchar(255)	,			
	var_StatusCode	      int(11)		,			
	var_StatusReason      int(10)       
	
)									
BEGIN									
	-- --------------------------------------------------------------------------
	-- #1 :: Declaration
	-- --------------------------------------------------------------------------
	DECLARE var_ModifiedOn	DateTime;
    DECLARE var_ModifiedBy varchar(36);

	DECLARE error_InvalidInputs                 CONDITION FOR SQLSTATE 'HY000';								
									
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		RESIGNAL ;
	END;

	-- --------------------------------------------------------------------------								
	-- #2 :: Variable Initialization								
	-- --------------------------------------------------------------------------								
	SET	var_WidgetId		= IFNULL(var_WidgetId,'');
	SET var_Name			= IFNULL(var_Name,'');
	SET var_Content			=IFNULL(var_Content,'');
	SET var_Type			=IFNULL(var_Type,'');
	SET var_DisplayDuration =IFNULL(var_DisplayDuration,'');
	SET var_DisplayLocation =IFNULL(var_DisplayLocation,'');
	SET var_StatusCode		=IFNULL(var_StatusCode,'0');
	SET var_StatusReason	=IFNULL(var_StatusReason,'0');
	SET	var_ModifiedBy		= '';
	SET var_ModifiedOn		= UTC_TimeStamp();	

	-- --------------------------------------------------------------------------								
	-- #3 :: Validation
	-- --------------------------------------------------------------------------		
	-- a) Mandatory Fields
	SELECT IFNULL(UserID,'') INTO var_ModifiedBy FROM User_Base WHERE AuthToken = var_AuthToken;

	IF(TRIM(var_Name) = '' OR TRIM(var_ModifiedBy) = '' OR TRIM(var_WidgetId) = '') THEN								
		SIGNAL error_InvalidInputs								
		SET MESSAGE_TEXT    = 'Mandatory Fields are not provided. `WidgetId`, `Name` and `ModifiedBy` are mandatory.', 								
			MYSQL_ERRNO     = 2002;         								
	END IF;


	-- --------------------------------------------------------------------------								
	-- #4 :: Update Record								
	-- --------------------------------------------------------------------------								
	START TRANSACTION;								

		SET @var_RowsUpdated = 0;
									
		UPDATE	WebWidget_Base
		SET		Name					= IF(var_Name				= ''		, Name				, var_Name				),
				Content					= IF(var_Content			= ''		, Content			, var_Content			),
				Type					= IF(var_Type			    = ''		, Type			    , var_Type			    ),
				DisplayLocation			= IF(var_DisplayLocation	= ''		, DisplayLocation	, var_DisplayLocation	),
				DisplayDuration			= IF(var_DisplayDuration	= ''		, DisplayDuration   , var_DisplayDuration	),
				StatusCode				= var_StatusCode,
				StatusReason			= IF(var_StatusReason	    = ''		, StatusReason		, var_StatusReason		),
				ModifiedBy				= IF(var_ModifiedBy			= ''		, ModifiedBy		, var_ModifiedBy		),
				ModifiedOn				= var_ModifiedOn																				
		WHERE	WebWidgetId				= var_WidgetId;
	
		SELECT ROW_COUNT() INTO @var_RowsUpdated;

	COMMIT;									

	SELECT @var_RowsUpdated AffectedRows;
						
END //									
DELIMITER ;									
